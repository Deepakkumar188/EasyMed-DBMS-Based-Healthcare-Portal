// EasyMed – main.js
document.addEventListener('DOMContentLoaded', () => {
  // Sidebar toggle
  window.toggleSidebar = () => {
    document.getElementById('sidebar')?.classList.toggle('open');
  };

  // Auto-dismiss alerts after 5s
  document.querySelectorAll('.alert:not(.alert-permanent)').forEach(a => {
    setTimeout(() => { try { bootstrap.Alert.getOrCreateInstance(a).close(); } catch(e){} }, 5000);
  });

  // Notification polling (dashboard pages)
  if (document.getElementById('notifCount')) loadNotifications();

  // Active nav link highlight
  const path = window.location.pathname;
  document.querySelectorAll('#mainNav .nav-link').forEach(link => {
    if (link.getAttribute('href') === path) link.classList.add('active');
  });
});

async function loadNotifications() {
  try {
    const res = await fetch('/api/notifications');
    const data = await res.json();
    const badge = document.getElementById('notifCount');
    const list  = document.getElementById('notifList');
    if (data.unread > 0) { badge.textContent = data.unread; badge.style.display = 'block'; }
    else badge.style.display = 'none';
    if (list) {
      list.innerHTML = data.notifications.length
        ? data.notifications.map(n => `
            <div class="notif-item ${n.is_read ? '' : 'unread'}">
              <div class="fw-semibold" style="font-size:13px">${n.title}</div>
              <div class="text-muted" style="font-size:12px">${n.message.substring(0,70)}…</div>
              <div class="text-muted" style="font-size:11px">${new Date(n.created_at).toLocaleString('en-IN')}</div>
            </div>`).join('')
        : '<div class="p-3 text-center text-muted small">No notifications</div>';
    }
  } catch(e) {}
}

async function markAllRead() {
  await fetch('/api/notifications/read', { method: 'POST' });
  loadNotifications();
}

function togglePass(id, btn) {
  const f = document.getElementById(id);
  f.type = f.type === 'password' ? 'text' : 'password';
  btn.innerHTML = f.type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>';
}
