#
# Ronin - A Ruby platform for exploit development and security research.
#
# Copyright (c) 2009-2010 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

require 'ronin/credential'
require 'ronin/model'

require 'digest'

module Ronin
  class Password

    include Model

    # Primary key of the password
    property :id, Serial

    # The clear-text of the password
    property :clear_text, String, :required => true,
                                  :unique => true

    # The credentials which use the password
    has 0..n, :credentials

    # The user names which use the password
    has 0..n, :user_names, :through => :credentials

    #
    # Hashes the password.
    #
    # @param [Symbol, String] digest
    #   The digest algorithm to use.
    #
    # @param [Hash] options
    #   Additional options.
    #
    # @option options [String] :prepend_salt
    #   The salt data to prepend to the password.
    #
    # @option options [String] :append_salt
    #   The salt data to append to the password.
    #
    # @return [String]
    #   The hex-digest of the hashed password.
    #
    # @raise [ArgumentError]
    #   Unknown Digest alogrithm.
    #
    # @example
    #   pass = Password.new(:clear_text => 'secret')
    #   
    #   pass.digest(:sha1)
    #   # => "e5e9fa1ba31ecd1ae84f75caaa474f3a663f05f4"
    #   
    #   pass.digest(:sha1, :prepend_salt => "A\x90\x00")
    #   # => "e2817656a48c49f24839ccf9295b389d8f985904"
    #   
    #   pass.digest(:sha1, :append_salt => "BBBB")
    #   # => "aa6ca21e446d425fc044bbb26e950a788444a5b8"
    #
    # @since 1.0.0
    #
    def digest(algorithm,options={})
      digest_class = begin
                       Digest.const_get(algorithm.to_s.upcase)
                     rescue LoadError
                       raise(ArgumentError,"Unknown Digest algorithm #{algorithm}")
                     end

      hash = digest_class.new

      if options[:prepend_salt]
        hash << options[:prepend_salt].to_s
      end

      hash << self.clear_text

      if options[:append_salt]
        hash << options[:append_salt].to_s
      end

      return hash.hexdigest
    end

    #
    # The number of credentials which use this password.
    #
    # @return [Integer]
    #   The number of credentials that use the password.
    #
    # @since 1.0.0
    #
    def count
      self.credentials.count
    end

    #
    # Converts the password into a String.
    #
    # @return [String]
    #   The clear-text of the password.
    #
    # @since 1.0.0
    #
    def to_s
      self.clear_text
    end

  end
end