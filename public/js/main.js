$(function() {
    $("textarea").autogrow();

    $(".delete-issue").on("submit", function(event) {
        event.preventDefault();

        var url = $(this).attr("action"),
            data = $(this).serialize(),
            method = $(this).attr("method");

        swal({
            title: "Are you sure you want to delete this issue?",
            text: "Along with the issue, all attachments will be deleted.\n\nThe issue (with attachments) will be lost forever! (A long time!)",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: "#DD6B55",
            confirmButtonText: "Yes, delete it!",
            closeOnConfirm: false,
            html: false
        }, function() {
            $.ajax({
                url: url,
                method: method,
                data: data,
                success: function(data) {
                    swal({
                        title: "Deleted!",
                        text: "The issue has been deleted.",
                        type: "success",
                        showCancelButton: false,
                        closeOnConfirm: false,
                        html: false
                    }, function() {
                        window.location.replace("/issues");
                    });
                },
                error: function(jqXHR, error, errorThrown) {
                    swal({
                        title: "Could not delete issue",
                        text: "An error occurred and the issue could not be deleted.",
                        type: "error"
                    });
                }
            });
        });
    });



    $(".input_file").on("change", function() {
        var file_input = $(this).get(0);
        if (typeof file_input === "object" && file_input.files.length === 0) {
            $(".files-to-upload").text("No file chosen");
        } else if (typeof file_input === "object" && file_input.files.length === 1) {
            $(".files-to-upload").text(file_input.files[0].name);
        } else if (typeof file_input === "object" && file_input.files.length > 1) {
            $(".files-to-upload").text(file_input.files.length + " files chosen");
        }
    });
});
