module SpecHelpers
  def spec_validate_attributes(expected_attributes, model, model_rendered)
    expected_attributes.sort!

    keys = model_rendered.keys.sort!
    expect(expected_attributes).to eq(keys)

    model_rendered.each do |key, value|
      if model.respond_to?(key)
        expect(model.send(key)).to eq(value)
      else
        expect(model[key]).to eq(value)
      end
    end
  end
end
