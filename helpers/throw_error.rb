def throw_error(app:, code: nil, message: nil)
    status code unless code == nil
    status_message = ""
    message.split(" ").each do |word|
        status_message << "#{word.capitalize} "
    end
    @error = {code: code, message: status_message}
    app.slim :error
end