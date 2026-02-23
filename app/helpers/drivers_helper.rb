# frozen_string_literal: true

module DriversHelper
  def clickable_address(address, label: nil, provider: :google)
    return "N/A" if address.blank?

    text = label.presence || address
    maps_url = case provider.to_s
    when "apple"
      "https://maps.apple.com/?q=#{ERB::Util.url_encode(address)}"
    else
      "https://www.google.com/maps/search/?api=1&query=#{ERB::Util.url_encode(address)}"
    end
    link_to(text, maps_url, target: "_blank", rel: "noopener noreferrer")
  end

  def clickable_address_with_options(address, label: nil)
    return "N/A" if address.blank?

    text = label.presence || address
    safe_join(
      [
        clickable_address(address, label: text, provider: :google),
        " ",
        safe_join(["(", clickable_address(address, label: "Apple Maps", provider: :apple), ")"])
      ]
    )
  end
end
