/**
 * WarVM relay — maps 6-char codes to Cloudflare Tunnel URLs.
 * Deployed as a Cloudflare Worker with a KV namespace (SESSIONS).
 *
 * Routes:
 *   POST   /register        { code, url, ttl? }  →  { ok: true }
 *   GET    /lookup/:code                          →  { url }
 *   DELETE /register/:code                        →  { ok: true }
 */

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS },
  });
}

export default {
  async fetch(request, env) {
    const { method } = request;
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS preflight
    if (method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS });
    }

    // POST /register
    if (method === 'POST' && path === '/register') {
      let body;
      try { body = await request.json(); } catch { return json({ error: 'Bad JSON' }, 400); }

      const { code, url: tunnelUrl, ttl = 86400 } = body;

      if (typeof code !== 'string' || !/^[A-Z0-9]{6}$/.test(code)) {
        return json({ error: 'code must be 6 uppercase alphanumeric chars' }, 400);
      }
      if (typeof tunnelUrl !== 'string' || !tunnelUrl.startsWith('https://')) {
        return json({ error: 'url must be a https URL' }, 400);
      }

      await env.SESSIONS.put(code, tunnelUrl, { expirationTtl: Math.min(ttl, 86400) });
      return json({ ok: true });
    }

    // GET /lookup/:code
    if (method === 'GET' && path.startsWith('/lookup/')) {
      const code = path.slice('/lookup/'.length).toUpperCase().trim();
      if (!/^[A-Z0-9]{6}$/.test(code)) return json({ error: 'Invalid code' }, 400);

      const tunnelUrl = await env.SESSIONS.get(code);
      if (!tunnelUrl) return json({ error: 'Code not found or expired' }, 404);

      return json({ url: tunnelUrl });
    }

    // DELETE /register/:code
    if (method === 'DELETE' && path.startsWith('/register/')) {
      const code = path.slice('/register/'.length).toUpperCase().trim();
      await env.SESSIONS.delete(code);
      return json({ ok: true });
    }

    return json({ service: 'warvm-relay', status: 'ok' });
  },
};
