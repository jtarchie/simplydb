module SimplyDB
  module Error
    # ref http://docs.amazonwebservices.com/AmazonSimpleDB/latest/DeveloperGuide/APIError.html
    class AccessFailure < RuntimeError; end
    class AttributeDoesNotExist < RuntimeError; end
    class AuthFailure < RuntimeError; end
    class AuthMissingFailure < RuntimeError; end
    class ConditionalCheckFailed < RuntimeError; end
    class ExistsAndExpectedValue < RuntimeError; end
    class FeatureDeprecated < RuntimeError; end
    class IncompleteExpectedExpression < RuntimeError; end
    class InternalError < RuntimeError; end
    class InvalidAction < RuntimeError; end
    class InvalidHTTPAuthHeader < RuntimeError; end
    class InvalidHttpRequest < RuntimeError; end
    class InvalidLiteral < RuntimeError; end
    class InvalidNextToken < RuntimeError; end
    class InvalidNumberPredicates < RuntimeError; end
    class InvalidNumberValueTests < RuntimeError; end
    class InvalidParameterCombination < RuntimeError; end
    class InvalidParameterValue < RuntimeError; end
    class InvalidQueryExpression < RuntimeError; end
    class InvalidResponseGroups < RuntimeError; end
    class InvalidService < RuntimeError; end
    class InvalidSOAPRequest < RuntimeError; end
    class InvalidSortExpression < RuntimeError; end
    class InvalidURI < RuntimeError; end
    class InvalidWSAddressingProperty < RuntimeError; end
    class InvalidWSDLVersion < RuntimeError; end
    class MalformedSOAPSignature < RuntimeError; end
    class MissingAction < RuntimeError; end
    class MissingParameter < RuntimeError; end
    class MissingWSAddressingProperty < RuntimeError; end
    class MultipleExistsConditions < RuntimeError; end
    class MultipleExpectedNames < RuntimeError; end
    class MultipleExpectedValues < RuntimeError; end
    class MultiValuedAttribute < RuntimeError; end
    class NoSuchDomain < RuntimeError; end
    class NoSuchVersion < RuntimeError; end
    class NotYetImplemented < RuntimeError; end
    class NumberDomainsExceeded < RuntimeError; end
    class NumberDomainAttributesExceeded < RuntimeError; end
    class NumberDomainBytesExceeded < RuntimeError; end
    class NumberItemAttributesExceeded < RuntimeError; end
    class NumberSubmittedAttributesExceeded < RuntimeError; end
    class NumberSubmittedItemsExceeded < RuntimeError; end
    class RequestExpired < RuntimeError; end
    class RequestTimeout < RuntimeError; end
    class ServiceUnavailable < RuntimeError; end
    class TooManyRequestedAttributes < RuntimeError; end
    class UnsupportedHttpVerb < RuntimeError; end
    class UnsupportedNextToken < RuntimeError; end
    class URITooLong < RuntimeError; end

    #Standard AWS errors
    class SignatureDoesNotMatch < RuntimeError; end
    class InvalidClientTokenId < RuntimeError; end
    class InvalidRequest < RuntimeError; end
  end
end