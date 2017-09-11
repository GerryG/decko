RSpec::Matchers.define :be_valid do
  match do |card|
    value_match?(true, card.errors.empty?)
  end
end

RSpec::Matchers.define :increase_card_count_by do |count|
  def supports_block_expectations?
    true # or some logic
  end

  match do |card_creation|
    count += Card.count
    card_creation.call
    vales_match?(Card.count, count)
  end
end

RSpec::Matchers.define :be_invalid do
  match do |card|
    # valid? clears errors
    # For a new card we have to call valid? to create the errors.
    # For a updated card we have to check errors because with valid? we would
    # loose the errors.
    @valid = card.errors.empty? && card.valid?
    # card.errors returns an array, hence we need an extra include matcher
    values_match?(false, @valid) &&
      values_match?(include(@error_msg), card.errors[@error_key])
  end

  description do
    "be invalid #{"because of #{@error_key} #{@error_msg}" if @error_key}"
  end

  chain(:because_of) do |reason|
    @error_key, @error_msg = reason.to_a.first
  end

  failure_message do |actual|
    super() + fail_reason(actual)
  end

  def fail_reason actual
    if @valid
      "but file is valid"
    else
      "but it is invalid because of #{actual.errors.messages}"
    end
  end
end

RSpec::Matchers.define :have_file do |trait|
  match do |card|
    trait ||= :file
    (@file = card.fetch(trait: trait)) && file_size_matches
  end

  description do
    "have a file attached #{"of size #{@size}" if @size}"
  end

  chain(:of_size) { |size| @size = size }

  failure_message do |_actual|
    if @size
      "#{super()} but file size is #{@file.file.size}"
    else
      "#{super()} but found no file"
    end
  end

  failure_message_when_negated do |_actual|
    if @size
      "#{super()} but file size is #{@file.file.size}"
    else
      "#{super()} but found a file"
    end
  end

  private

  def file_size_matches
    return true unless @size
    @size === @file.file.size
  end
end
