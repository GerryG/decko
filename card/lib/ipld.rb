require 'ffi'

module Ipld
  extend FFI::Library

  ffi_lib './libipld.so'
  attach_function :go_publish, [:string], :string

  def publish card, user, changes
    h['type'] = card.type.lpfs_hash if changes['type_id']
    if changes['name'] {
      h['name'] = card.name
      h['key'] = card.key
    }
    h['author'] = user.lpfs_hash
    card.lpfs_hash = go_publish JSON.generate(h)
  end
end
