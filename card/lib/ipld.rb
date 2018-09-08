require 'ffi'

module Ipld
  extend FFI::Library

  begin
    ffi_lib 'libcard.so' # set LD_LIBRARY_PATH to .so dir
    attach_function :ipldpublish, [:string], :string
  rescue => e
    Rails.logger.info "Could not attache libcard.so, #{e.message}"
    raise "Not attached libipld"
  end

  class << self
    def publish card, user, changes
      Rails.logger.info "pub C:#{card} U:#{user}, chg:#{changes}"
      h = {}
      ipldpublish JSON.generate(h) if h.any?
    end
  end
end
