require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  def test_company
    companies(:hometown_painting)
  end

  test 'name -> empty not allowed' do
    test_company.name = nil
    assert_not test_company.valid?
  end

  test 'zip_code -> empty not allowed' do
    test_company.zip_code = nil
    assert_not test_company.valid?
  end

  test 'zip_code -> invalid check' do
    test_company.zip_code = "0000"
    assert_not test_company.valid?
  end

  test 'zip_code -> updates city & state if valid' do
    test_company.zip_code = "12345"
    assert test_company.valid?
    assert test_company.save
    test_company.reload
    zip_code_data = ZipCodes.identify("12345")
    assert_equal zip_code_data[:city], test_company.city
    assert_equal zip_code_data[:state_code], test_company.state
  end

  test 'email -> empty allowed' do
    test_company.email = nil
    assert test_company.valid?
    assert test_company.save
  end

  test 'email -> invalid domain' do
    test_company.email = "abc@test.com"
    assert_not test_company.valid?
  end

  test 'email -> invalid email pattern' do
    test_company.email = "abc"
    assert_not test_company.valid?
  end
end
