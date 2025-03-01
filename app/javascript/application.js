// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

document.addEventListener('turbo:load', () => {
  // Make table rows clickable (except for links/buttons inside them)
  document.querySelectorAll('.clickable-row').forEach(row => {
    row.addEventListener('click', function(event) {
      if (event.target.closest('a') || event.target.closest('button')) {
        return;
      }
      window.location = this.dataset.href;
    });
  });

  // Flash message auto-hide after 5 seconds
  let flashMessage = document.querySelector(".alert");
  if (flashMessage) {
    setTimeout(() => {
      flashMessage.style.transition = "opacity 2s ease-in-out";
      flashMessage.style.opacity = "0";
      setTimeout(() => flashMessage.remove(), 2000); 
    }, 5000); 
  }
});
