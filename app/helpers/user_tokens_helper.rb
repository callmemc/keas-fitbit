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
        s = "<div style='margin-left:#{indent}px;'>"
        hasSpeed = data["hasSpeed"] != nil && data["hasSpeed"] != "false"

        hasName = data['name'] != nil
        name = data['name'] if hasName

        hasId = data["id"] != nil
        id = data["id"] if hasId

        hasMets = data["mets"] != nil
        mets = data["mets"].to_f.round if hasMets
        ids = {:id => 12, :activity_id => id}
        url = show_activities_user_token_url(ids)

        s += "#{data['name']}" unless hasId
        s += "<a href='#{show_activity_user_token_url()}?id=12&activity_id=#{id}'>#{id} - #{name}</a>"  if hasId
        s += " (Mets:#{mets}) " if hasMets
        data.each do |k,v|
            next if ["mets","hasSpeed", "accessLevel", "name","id"].include?(k)
            next if ["maxSpeedMPH","minSpeedMPH"].include?(k) && hasSpeed
            next if v.class == Array || v.class == Hash
            s += "#{k}: #{v} " if v.class == String
            s += "#{k}: #{v.to_s} " if v.class != String
        end
        data.each do |k,v|
            next if ["mets","hasSpeed", "accessLevel", "name","id"].include?(k)
            next if ["maxSpeedMPH","minSpeedMPH"].include?(k) && hasSpeed
            next if v.class != Array && v.class != Hash
            s += "<p /><span style='margin-left:#{indent+10}px;'>#{k}:</span>#{expand_array(v, indent+ 20)}" if v.class == Array
            s += "<p /><span style='margin-left:#{indent+10}px;'>#{k}:</span><p />#{expand_hash(v,indent+20)}" if v.class == Hash
        end
        s += "</div>"
    end

end
