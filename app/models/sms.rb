class Sms
  include MongoMapper::Document
  # http://www.txtlocal.co.uk/developers/docs
  key :raw_message, String
  key :sender, String   # The mobile number of the handset.
  key :content, String  # The message content.
  key :inNumber, String # The number the message was sent to (your inbound number).
  key :email, String    # Any email address extracted.
  key :credits, String  # The number of credits remaining on your Txtlocal account.
  key :lat, String      # The latitude of the handset (LBS only).
  key :long, String     # The longitude of the handset (LBS only).
  key :rad, String      # The radius of error for the location (LBS only).
  key :lbscredits, String # The number of location credits remaining on your Txtlocal account (LBS only).
  timestamps!
end
