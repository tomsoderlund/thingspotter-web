class InvitationsController < ApplicationController

  def index
    if (is_admin?)
      @invitations = Invitation.find(:all, :include => [:sender, :recipient], :conditions => ["recipients_invitations.invitation_id IS NULL"], :order => 'invitations.created_at desc')
    else
      redirect_to root_path 
    end
  end

  def new
    @invitation = Invitation.new
    @user = User.find(params[:id]) if params[:id]

    respond_to do |format|
      format.html {}
      format.js {}
    end
  end

  def create
    @invitation = Invitation.new(params[:invitation])
    @invitation.sender = current_user
    if @invitation.save
      if logged_in?
        # 0 = none, 1 = English, 2 = Swedish
        if (params[:invitation_type] == '0')
          flash[:notice] = "Invitation created (not emailed out): #{$SERVER_URL}/intro/#{@invitation.token}"
        else
          Emailer.deliver_invitation(@invitation, params[:name], intro_invitation_url(@invitation.token), params[:invitation_type])
          flash[:notice] = "Thank you, invitation sent to #{@invitation.recipient_email}"
        end
        respond_to do |format|
          format.html { redirect_to root_url }
          format.js {}
        end
      else
        flash[:notice] = "Thank you, we will notify you when we are ready."
        respond_to do |format|
          format.html {}
          format.js {}
        end
      end
    else
      respond_to do |format|
        flash[:error] = @invitation.errors.full_messages
        format.html { render :action => 'new' }
        format.js {}
      end
    end
  end
  
  # Update = re-send email
  def update
    @invitation = Invitation.find(params[:id])
    
    if (params[:invitation_type] == '0')
      flash[:notice] = "Invitation created (not emailed out): #{$SERVER_URL}/intro/#{@invitation.token}"
    else
      Emailer.deliver_invitation(@invitation, nil, intro_invitation_url(@invitation.token), params[:invitation_type])
      flash[:notice] = "Invitation sent to #{@invitation.recipient_email}"
    end
    respond_to do |format|
      format.html { redirect_to invitations_url }
      format.js {}
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    flash[:invitation_id] = @invitation.id
    @invitation.destroy
    respond_to do |format|
      format.html { redirect_to(invitations_path) }
      format.js
      format.xml  { head :ok }
    end
  end
  
end