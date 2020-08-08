require "test_helper"
require "application_system_test_case"

class CompaniesControllerTest < ApplicationSystemTestCase

  def setup
    @company = companies(:hometown_painting)
  end

  test "Index" do
    visit companies_path

    assert_text "Companies"
    assert_text "Hometown Painting"
    assert_text "Wolf Painting"
  end

  test "Show" do
    visit company_path(@company)

    assert_text @company.name
    assert_text @company.phone
    assert_text @company.email
    assert_text "#{@company.city}, #{@company.state}"
  end

  test "Update" do
    visit edit_company_path(@company)

    within("form#edit_company_#{@company.id}") do
      fill_in("company_name", with: "Updated Test Company")
      fill_in("company_zip_code", with: "93009")
      click_button "Update Company"
    end

    assert_text "Changes Saved"

    @company.reload
    assert_equal "Updated Test Company", @company.name
    assert_equal "93009", @company.zip_code
    zip_code_data = ZipCodes.identify("93009")
    assert_equal zip_code_data[:city], @company.city
    assert_equal zip_code_data[:state_code], @company.state
  end

  test "Update with invalid zip_code" do
    visit edit_company_path(@company)

    within("form#edit_company_#{@company.id}") do
      fill_in("company_zip_code", with: "0000")
      click_button "Update Company"
    end

    assert_text I18n.t('error_message.zip_code.empty')

    @company.reload
    assert_not_equal "0000", @company.zip_code
  end

  test "Update with invalid email domain" do
    visit edit_company_path(@company)

    within("form#edit_company_#{@company.id}") do
      fill_in("company_email", with: "abc@test.com")
      click_button "Update Company"
    end

    assert_text I18n.t('error_message.email.invalid_domain', allowed_domains: Company::ALLOWED_EMAIL_DOMAINS.join(', '))

    @company.reload
    assert_not_equal "abc@test.com", @company.email
  end

  test "Update with invalid email pattern" do
    visit edit_company_path(@company)

    within("form#edit_company_#{@company.id}") do
      fill_in("company_email", with: "abc")
      click_button "Update Company"
    end

    assert_text I18n.t('error_message.email.invalid_email')

    @company.reload
    assert_not_equal "abc", @company.email
  end

  test "Create" do
    visit new_company_path

    within("form#new_company") do
      fill_in("company_name", with: "New Test Company")
      fill_in("company_zip_code", with: "28173")
      fill_in("company_phone", with: "5553335555")
      fill_in("company_email", with: "new_test_company@getmainstreet.com")
      click_button "Create Company"
    end

    assert_text "Saved"

    last_company = Company.last
    assert_equal "New Test Company", last_company.name
    assert_equal "28173", last_company.zip_code
    zip_code_data = ZipCodes.identify("28173")
    assert_equal zip_code_data[:city], last_company.city
    assert_equal zip_code_data[:state_code], last_company.state
  end

   test "Destroy" do
    visit company_path(@company)

    total_companies = Company.count
    @company.destroy
    assert_equal total_companies - 1, Company.count
  end
end
