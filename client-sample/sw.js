self.addEventListener('push', function(event) {
  if (event.data) {
    console.log(event.data.json());
  }
});
