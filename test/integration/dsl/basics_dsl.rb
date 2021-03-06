module BasicsDsl

  def view
    filename = File.dirname(__FILE__) + "/../../../public/.integration_test_output_for_browser.html"
    flunk("There was no response to view") unless response
    File.open(filename, "w+") { | file | file.write(response.body) }
    `open #{filename}`
  end

  def login(login, password = "test")
    post session_url, { :login => login, :password => password }
    result = response.redirect_url == community_home_url
    follow_redirect! while redirect?
    result
  end

  def logout
    get_via_redirect logout_url
  end

  def click_link(link_text, method = :get)
    assert_select("a", link_text, "Trying to click a link named '#{link_text}' that did not exist") do | links |
      address = links.first.attributes['href']
      return get_via_redirect(address) if method == :get
      return post_via_redirect(address) if method == :post
      return delete_via_redirect(address) if method == :delete
    end
  end

  def assert_link_exists(link_text)
    assert_select("a", link_text, "Expected the link '#{link_text}' to exist.")
  end

  def assert_link_does_not_exist(link_text)
    assert_select("a", { :text => link_text, :count => 0 }, "Did not expect the link '#{link_text}' to exist.")
  end

  def assert_flash(expected_flash_value)
    assert_select("div#flash p", expected_flash_value, "Expected the flash to be '#{expected_flash_value}'")
  end

  def assert_validation_error(error_text)
    assert_select("div.errorExplanation ul>li", error_text, "Expected there to be a validation error of '#{error_text}'")
  end

  def assert_logged_in(user_or_user_symbol)
    user = user_or_user_symbol.kind_of?(User) ? user_or_user_symbol : users(user_or_user_symbol)
    assert_equal(user.id, session[:user_id], "#{user} should have been logged in.")
  end

  def assert_not_logged_in
    assert_nil(session[:user_id], "No user should be logged in.")
  end

end
