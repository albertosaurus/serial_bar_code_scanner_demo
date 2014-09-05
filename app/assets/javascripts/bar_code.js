$(document).ready(function() {
    if ($("#scanner_output").length) {
        var scanner_stomp_client = new Stomp.Client();

        scanner_stomp_client.connect(function () {
            // executed once successfully connected
            scanner_stomp_client.subscribe("/bar_code_scanner", function (message) {
                $("#scanner_output").text(message.body);
            });
        });
    }
});