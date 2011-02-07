class SmsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def callback
    # 'sender' 'content' 'inNumber' 'email' 'credits' 'lat' 'long' 'rad' 'lbscredits'
    if @sms = Sms.create(params)
      render :action => "last"
    else
      # save raw message and email admin
      Sms.create(:raw_message => params)
      redirect_to root_url
    end
  end

  def last
    render :json => Sms.all.last.as_json
  end
end
