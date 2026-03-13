// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@rails/ujs" 

// Confirm deletion for button_to forms
document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll('form button[data-confirm]').forEach((btn) => {
    btn.addEventListener("click", (e) => {
      const message = btn.getAttribute("data-confirm");
      if (!confirm(message)) {
        e.preventDefault(); // Stop the form from submitting
      }
    });
  });
});