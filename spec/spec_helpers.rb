module SpecHelpers
  def spec_validate_attributes(expected_attributes, model, model_rendered, expected_attributes_to_skip = [])
    expected_attributes.sort!

    keys = model_rendered.keys.sort!
    expect(keys).to eq(expected_attributes)

    model_rendered.each do |key, value|
      next if expected_attributes.include?(key)

      if model.respond_to?(key)
        expect(value).to eq(model.send(key))
      else
        expect(value).to eq(model[key])
      end
    end
  end
end
