def throw_error(app:, code: nil, message: nil)
    status code unless code == nil
    status = ""
    message.split(" ").each do |word|
        status << "#{word.capitalize} "
    end
    @error = {code: code, message: status}
    app.slim :error
end
