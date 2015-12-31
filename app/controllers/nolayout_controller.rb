class NolayoutController < ApplicationController
  
  def syncIpad
    existing =  Customer.find_by_email(params[:email])
    customer = Customer.new(:first_name => params[:customerName], :email => params[:email])
    if existing == nil
      customer.save
      respond = 'yes'
    else
      respond = 'no'
    end
    respond_to do |format|
      format.json { render :json => '{ "status": "' + respond + '"}' }
    end
  end
  
  def choosepass
    @customer = Customer.find_by_email(params[:email])
    if params[:customer] != nil
      @cust = Customer.find(params[:custid])
      @cust.update_attributes(params[:customer])
      redirect_to('/')
    end
  end
  
  def test
    words = L.split(' ').to_a
    my_string = S.to_s
    
    
    positions = []
    
    for w in words
      position = my_string.split(w)
      word = {
        'thisword' => "#{w}",
        'length' => "#{w.length}", 
        'start' => "#{(position[0].length.to_i + 1)}", 
        'ending' => "#{(position[0].length.to_i+w.length.to_i)}"
        }
      positions << word
    end
    positions.sort!{ |a,b| a['start'] <=> b['start'] }.to_s
    
    start_position = positions[0]['start']
    end_position = positions[(positions.count-1).to_i]['ending']
    word_sequence = ''
    for w in positions
      word_sequence += w['thisword']
    end
    
    @answer = start_position.to_s
  end
  
  def logoff_merchant
    session[:company_id] = nil
    redirect_to('/')
  end
  
end
