module UserTokensHelper

    def expand_fit_data data, title
        s = "<p>#{title}</p>"
        indent = 0
        s += expand_hash data, indent
        s.html_safe
    end

    def expand_array data, indent
        s = "<div style='margin-left:#{indent}px;'>"
        data.each do |h|
            s += "#{expand_hash h, indent + 10}<p />"
        end
        s += "</div>"
        s
    end

    def expand_hash data, indent
        s = "EH:#{data['name']}-#{data['id']} - <span style='margin-left:#{indent}px;'>"
        hasSpeed = data["hasSpeed"] != nil && data["hasSpeed"] != "false"

        hasId = data["id"] != nil
        id = data["id"] if hasId

        hasMets = data["mets"] != nil
        mets = data["mets"].to_f.round if hasMets
        s = "EH:#{data['name']}"
        s += "(id:#{data['id']}) " if hasId
        s += " (Mets:#{mets}) " if hasMets

        s += "<span style='margin-left:#{indent}px;'>"
        data.each do |k,v|
            next if ["mets","hasSpeed", "accessLevel", "name","id"].include?(k)
            next if ["maxSpeedMPH","minSpeedMPH"].include?(k) && hasSpeed
            s += "#{k}:"
            s += expand_array(v, indent+ 10) if v.class == Array
            s += "#{v} " if v.class == String
            s += "#{v.to_s} " if v.class != Array && v.class != String
        end
        s += "</span>"
    end

end
