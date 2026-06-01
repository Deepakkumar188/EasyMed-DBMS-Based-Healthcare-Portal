// EasyMed – dashboard.js  (Chart.js helpers)
function initAdminCharts(revenueData, deptData) {
  // Revenue Line Chart
  const rCtx = document.getElementById('revenueChart');
  if (rCtx && revenueData) {
    new Chart(rCtx, {
      type: 'bar',
      data: {
        labels: revenueData.map(r => r.month),
        datasets: [{
          label: 'Revenue (₹)',
          data: revenueData.map(r => r.revenue),
          backgroundColor: 'rgba(0,102,204,0.15)',
          borderColor: '#0066cc',
          borderWidth: 2,
          borderRadius: 6,
          fill: true
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { display: false } },
        scales: {
          y: { beginAtZero: true, grid: { color: '#f0f0f0' },
               ticks: { callback: v => '₹' + (v/1000).toFixed(0) + 'k' } },
          x: { grid: { display: false } }
        }
      }
    });
  }

  // Dept Doughnut Chart
  const dCtx = document.getElementById('deptChart');
  if (dCtx && deptData && deptData.length) {
    const colors = ['#0066cc','#00b894','#fd7e14','#e74c3c','#9b59b6','#f39c12','#17a2b8','#28a745'];
    new Chart(dCtx, {
      type: 'doughnut',
      data: {
        labels: deptData.map(d => d.dept_name),
        datasets: [{ data: deptData.map(d => d.appointments || 1),
                     backgroundColor: colors, borderWidth: 2, borderColor: '#fff' }]
      },
      options: { responsive: true, plugins: { legend: { position: 'bottom', labels: { font: { size: 11 }, boxWidth: 12 } } }, cutout: '65%' }
    });
  }
}

function initDoctorChart(data) {
  const ctx = document.getElementById('appointmentChart');
  if (!ctx) return;
  new Chart(ctx, {
    type: 'line',
    data: {
      labels: data.map(d => d.label),
      datasets: [{
        label: 'Appointments',
        data: data.map(d => d.count),
        borderColor: '#0066cc',
        backgroundColor: 'rgba(0,102,204,0.08)',
        tension: 0.4,
        fill: true
      }]
    },
    options: { responsive: true, plugins: { legend: { display: false } },
               scales: { y: { beginAtZero: true, grid: { color: '#f0f0f0' } }, x: { grid: { display: false } } } }
  });
}
