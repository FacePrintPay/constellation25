document.addEventListener('DOMContentLoaded', () => {
  const stamp = document.getElementById('timestamp');
  if (stamp) {
    stamp.textContent = `Updated: ${new Date().toLocaleString()}`;
  }
});
