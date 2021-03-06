#!/usr/bin/ruby -Eutf-8:utf-8
# encoding: UTF-8
# Copyright 2015-2016 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not
# use this file except in compliance with the License. A copy of the License
# is located at
#
#   http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
require_relative 'asn1ext'

module CertLint
class ASN1Ext
  class AuthorityKeyIdentifier < ASN1Ext
    @pdu = :AuthorityKeyIdentifier
    @critical_req = false

    def self.lint(content, cert, critical = false)
      messages = []
      messages += super(content, cert, critical)
      e = OpenSSL::X509::Extension.new('2.5.29.35', content, critical)
      keys = e.value.split(/\n/).map { |s| s.split(':').first }
      if keys.include? 'DirName'
        unless keys.include? 'serial'
          messages << 'E: AuthorityKeyIdentifier must include serial number if issuer is present'
        end
      elsif keys.include? 'serial'
        messages << 'E: AuthorityKeyIdentifier must include issuer if serial number is present'
      end

      messages
    end
  end
end
end

CertLint::CertExtLint.register_handler('2.5.29.35', CertLint::ASN1Ext::AuthorityKeyIdentifier)
