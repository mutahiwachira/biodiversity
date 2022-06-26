 $(function() {
    Shiny.addCustomMessageHandler(
      'toggle', function myFunction(message) {
        var x = document.getElementById(message);
        if (x.style.display === "none") {
          x.style.display = "block";
        } else {
          x.style.display = "none";
        }
      });
  });