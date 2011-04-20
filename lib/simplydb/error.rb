def HTTPError(status_code)
  klass = Class.new(SimplyDB::Error)
  klass.send(:define_method, :http_status_code) {status_code}
  klass
end

module SimplyDB
  class Error < RuntimeError
    def name
      self.class.name
    end
  end

  module Errors
    class AccessFailure < HTTPError(403); end
    class AttributeDoesNotExist < HTTPError(404); end
    class AuthFailure < HTTPError(403); end
    class AuthMissingFailure < HTTPError(403); end
    class ConditionalCheckFailed < HTTPError(409); end
    class ExistsAndExpectedValue < HTTPError(400); end
    class FeatureDeprecated < HTTPError(400); end
    class IncompleteExpectedExpression < HTTPError(400); end
    class InternalHTTPError < HTTPError(500); end
    class InvalidAction < HTTPError(400); end
    class InvalidHTTPAuthHeader < HTTPError(400); end
    class InvalidHttpRequest < HTTPError(400); end
    class InvalidLiteral < HTTPError(400); end
    class InvalidNextToken < HTTPError(400); end
    class InvalidNumberPredicates < HTTPError(400); end
    class InvalidNumberValueTests < HTTPError(400); end
    class InvalidParameterCombination < HTTPError(400); end
    class InvalidParameterValue < HTTPError(400); end
    class InvalidQueryExpression < HTTPError(400); end
    class InvalidResponseGroups < HTTPError(400); end
    class InvalidService < HTTPError(400); end
    class InvalidSOAPRequest < HTTPError(400); end
    class InvalidSortExpression < HTTPError(400); end
    class InvalidURI < HTTPError(400); end
    class InvalidWSAddressingProperty < HTTPError(400); end
    class InvalidWSDLVersion < HTTPError(400); end
    class MalformedSOAPSignature < HTTPError(403); end
    class MissingAction < HTTPError(400); end
    class MissingParameter < HTTPError(400); end
    class MissingWSAddressingProperty < HTTPError(400); end
    class MultipleExistsConditions < HTTPError(400); end
    class MultipleExpectedNames < HTTPError(400); end
    class MultipleExpectedValues < HTTPError(400); end
    class MultiValuedAttribute < HTTPError(409); end
    class NoSuchDomain < HTTPError(400); end
    class NoSuchVersion < HTTPError(400); end
    class NotYetImplemented < HTTPError(401); end
    class NumberDomainsExceeded < HTTPError(409); end
    class NumberDomainAttributesExceeded < HTTPError(409); end
    class NumberDomainBytesExceeded < HTTPError(409); end
    class NumberItemAttributesExceeded < HTTPError(409); end
    class NumberSubmittedAttributesExceeded < HTTPError(409); end
    class NumberSubmittedItemsExceeded < HTTPError(409); end
    class RequestExpired < HTTPError(400); end
    class RequestTimeout < HTTPError(408); end
    class ServiceUnavailable < HTTPError(503); end
    class TooManyRequestedAttributes < HTTPError(400); end
    class UnsupportedHttpVerb < HTTPError(400); end
    class UnsupportedNextToken < HTTPError(400); end
    class URITooLong < HTTPError(400); end

    #Standard AWS HTTPErrors
    class SignatureDoesNotMatch < HTTPError(400); end
    class InvalidClientTokenId < HTTPError(400); end
    class InvalidRequest < HTTPError(400); end
  end
end