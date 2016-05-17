class Attachment
    include DataMapper::Resource

    property :id, Serial
    property :uuid, String, required: true, unique: true
    property :file, FilePath, required: true
    property :created_at, EpochTime

    belongs_to :issue, required: false
    belongs_to :faq, required: false
    belongs_to :user

    def self.upload(app:, user:, issue:, params:)
        if params[:files]
            params[:files].each do |file|
                tmpfile = file[:tempfile]

                next if tmpfile.size.MB > 10

                filename = SecureRandom.urlsafe_base64
                extname = File.extname(file[:filename])

                unless Dir.exist?("uploads")
                    Dir.mkdir("uploads")
                end

                unless Dir.exist?("uploads/#{user.uuid}")
                    Dir.mkdir("uploads/#{user.uuid}")
                end

                while payload = tmpfile.read(65536)
                    File.open("uploads/#{user.uuid}/#{filename}#{extname}", "a+") do |file|
                        file.write(payload)
                    end
                end

                Attachment.create(uuid: SecureRandom.uuid, file: "/uploads/#{user.uuid}/#{filename}#{extname}", issue_id: issue.id, user_id: user.id)
            end
        end
    end

    def self.web_image?(file)
        web_image_extensions = [".gif", ".jpeg", ".jpg", ".png", ".svg"]
        return web_image_extensions.include?(File.extname(file))
    end

    def self.image?(file)
        image_extensions = [".bmp", ".cmx", ".cod", ".eps", ".gif", ".ico", ".ief", ".jfif", ".jpe", ".jpeg", ".jpg", ".pbm", ".pgm", ".png", ".ras", ".rgb", ".svg", ".tif", ".tiff", ".webp", ".xbm", ".xpm", ".xwd"]
        return image_extensions.include?(File.extname(file))
    end

    def self.audio?(file)
        audio_extensions = [".aif", ".aifc", ".aiff", ".au", ".fla", ".flac", ".m3u", ".mid", ".midi", ".mp3", ".ra", ".ram", ".rmi", ".snd", ".wav"]
        return audio_extensions.include?(File.extname(file))
    end

    def self.video?(file)
        video_extensions = [".asf", ".asr", ".asx", ".flv", ".lsf", ".lsx", ".mov", ".movie", ".mp2", ".mp4", ".mpa", ".mpe", ".mpeg", ".mpg", ".mpv2", ".swf", ".qt", ".webm", ".wmv"]
        return video_extensions.include?(File.extname(file))
    end

    def self.archive?(file)
        archive_extensions = [".7z", ".7zip", ".gtar", ".gz", ".jar", ".rar", ".tar", ".tgz", ".z", ".zip"]
        return archive_extensions.include?(File.extname(file))
    end

    def self.code?(file)
        code_extensions = [".asp", ".aspx", ".bas", ".bat", ".c", ".cgi", ".cpp", ".cs", ".class", ".coffee", ".css", ".do", ".ejs", ".erb", ".fs", ".go", ".haml", ".htm", ".html", ".jade", ".js", ".json", ".jsp", ".latex", ".less", ".lol", ".lua", ".php", ".pl", ".py", ".r", ".rb", ".rs", ".ru", ".sass", ".scss", ".sh", ".slim", ".stm", ".styl", ".swift", ".tex", ".texi", ".texinfo", ".ts", ".vb"]
        return code_extensions.include?(File.extname(file))
    end

    def self.text?(file)
        text_extensions = [".bin", ".cer", ".cmd", ".conf", ".config", ".crash", ".csv", ".dll", ".h", ".ini", ".log", ".man", ".markdown", ".md", ".mdown", ".mdwn", ".pem", ".rtf", ".skv", ".toml", ".tsv", ".txt", ".uls", ".xml", ".yaml", ".yml"]
        return text_extensions.include?(File.extname(file))
    end

    def self.ms_word?(file)
        ms_word_extensions = [".doc", ".docx", ".docm"]
        return ms_word_extensions.include?(File.extname(file))
    end

    def self.ms_powerpoint?(file)
        ms_powerpoint_extensions = [".ppt", ".pptx", ".pptm"]
        return ms_powerpoint_extensions.include?(File.extname(file))
    end

    def self.ms_excel?(file)
        ms_excel_extensions = [".xls", ".xlsx", ".xlsm"]
        return ms_excel_extensions.include?(File.extname(file))
    end

    def self.pdf?(file)
        return File.extname(file) == ".pdf"
    end
end
