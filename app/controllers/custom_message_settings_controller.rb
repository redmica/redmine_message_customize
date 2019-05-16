class CustomMessageSettingsController < ApplicationController
  layout 'admin'
  before_action :require_admin, :set_custom_message_setting, :set_lang
  require_sudo_mode :edit, :update

  def edit
  end

  def update
    original_custom_messages = @setting.custom_messages
    languages = (original_custom_messages.try(:keys) ? original_custom_messages.keys.map(&:to_s) : [])

    if setting_params.key?(:custom_messages) || params[:tab] == 'normal'
      @setting.update_with_custom_messages(setting_params[:custom_messages].try(:to_unsafe_h).try(:to_hash) || {}, @lang)
    elsif setting_params.key?(:custom_messages_yaml)
      @setting.update_with_custom_messages_yaml(setting_params[:custom_messages_yaml])
    end

    if @setting.errors.blank?
      flash[:notice] = l(:notice_successful_update)
      new_custom_messages = @setting.custom_messages
      languages += new_custom_messages.keys.map(&:to_s) if new_custom_messages.try(:keys)
      CustomMessageSetting.reload_translations!(languages)

      redirect_to edit_custom_message_settings_path(tab: params[:tab], lang: @lang)
    else
      render :edit
    end
  end

  private
  def set_custom_message_setting
    @setting = CustomMessageSetting.find_or_default
  end

  def setting_params
    params.fetch(:settings, {})
  end

  def set_lang
    @lang = CustomMessageSetting.find_language(params[:lang].presence || User.current.language.presence || 'en')
  end
end