# encoding: utf-8
class SessionsController < DeviseController
  prepend_before_action :allow_params_authentication!, only: [:create]
  prepend_before_action :require_no_authentication,    only: [:new, :create]
  skip_before_action    :verify_authenticity_token,    only: [:new, :create]

  def new
    session[:account_return_to] ||= url_for('/')
  end

  def create
    cookies.permanent[:https] = { value: "1", secure: false } if request.ssl?
    @account = warden.authenticate!(scope: :account, recall: "#{controller_path}#new")
    sign_in :account, @account
    redirect_to after_sign_in_path_for(:account), notice: I18n.t("devise.sessions.signed_in")
  rescue ActionController::RedirectBackError
    redirect_to '/'
  end

  def destroy
    cookies.delete :https
    sign_out :account
    redirect_to "/"
  end
end
