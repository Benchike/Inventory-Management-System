/* Who may see the LIF Project Manager and the other restricted tools
   (All On Grant Invoice, Sales Target Calculator).
   Shared by the home page and every restricted page. This only controls what the
   pages show — the database enforces the same list (add_lif_access_restriction.sql, add_restricted_tools_access.sql),
   so keep the two in step when adding or removing someone. */
(function(){
  var EMAILS = ["benokpala@ourkiru.com", "cole@ourkiru.com"];

  function allowed(email){
    return !!email && EMAILS.indexOf(String(email).trim().toLowerCase()) !== -1;
  }

  // Replace the whole page with a "no access" notice.
  function block(){
    document.title = "No access — Kiru Energy";
    document.body.innerHTML =
      '<div style="min-height:100vh;display:flex;align-items:center;justify-content:center;padding:24px;background:#f4f7fb;font-family:system-ui,-apple-system,Segoe UI,sans-serif">' +
        '<div style="max-width:420px;text-align:center;background:#fff;border:1px solid #e3e9f1;border-radius:14px;padding:32px 28px;color:#021431">' +
          '<div style="font-size:1.15rem;font-weight:800;margin-bottom:8px">You don\'t have access to this page</div>' +
          '<div style="font-size:.9rem;line-height:1.55;color:#56657a;margin-bottom:20px">This tool is limited to specific team members. If you need access, ask your manager.</div>' +
          '<a href="index.html" style="display:inline-block;background:#021431;color:#fff;text-decoration:none;font-weight:700;font-size:.85rem;padding:10px 20px;border-radius:9px">Back to Kiru Workspace</a>' +
        '</div>' +
      '</div>';
  }

  window.KiruLif = { emails: EMAILS, allowed: allowed, block: block };
})();
