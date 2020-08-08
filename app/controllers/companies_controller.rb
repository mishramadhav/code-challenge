class CompaniesController < ApplicationController
  before_action :set_company, except: [:index, :create, :new]

  def index
    @companies = Company.all
  end

  def new
    @company = Company.new
  end

  def show
    # adding this for lazy update of companies first time it is accessed
    # if some of them don't have city and state saved
    add_city_state unless (@company.city && @company.state).present?
    render :show
  end

  def create
    @company = Company.new(company_params)
    if @company.save
      redirect_to companies_path, notice: "Saved"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to companies_path, notice: "Changes Saved"
    else
      flash[:error] = "#{@company.errors.full_messages.join(', ')}"
      render :edit
    end
  end

  def destroy
    @company.destroy
    redirect_to companies_path, notice: I18n.t('company.destroy.success', name: @company.name)
  rescue ActiveRecord::ActiveRecordError => error
    Rails.logger.error("error: #{error.message}, backtrace: #{error.backtrace[0..10].split(",").join("")}")
    flash[:error] = I18n.t('company.destroy.failure', name: @company.name)
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :legal_name,
      :description,
      :zip_code,
      :phone,
      :email,
      :owner_id,
    )
  end

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to companies_path, notice: I18n.t('company.not_found', id: params[:id])
  end

  def add_city_state
    zip_code_data = ZipCodes.identify(@company.zip_code) || {}
    return unless zip_code_data.present?
    @company.update(city: zip_code_data[:city], state: zip_code_data[:state_code])
  end
end
