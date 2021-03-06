require File.dirname(__FILE__) + '/../test_helper'

class DiscussionsControllerTest < ActionController::TestCase
  context "DiscussionsController" do
    setup do
      ActionMailer::Base.deliveries = []

      @community = Community.make
      @gold = AccessClass.make(:community => @community)
      @silver = AccessClass.make(:community => @community)

      @registered_user = User.make(:community => @community)
      @gold_user = User.make(:community => @community, :access_class => @gold)
      @silver_user = User.make(:community => @community, :access_class => @silver)

      @public_theme = Theme.make(:community => @community)
      @registered_theme = Theme.make(:community => @community, :registered => true)
      @gold_theme = Theme.make(:community => @community, :registered => true, :access_classes => [@gold])
      @silver_theme = Theme.make(:community => @community, :registered => true, :access_classes => [@silver])
    end

    context "when a new discussion is created and members are signed up to receive emails on creation" do
      setup do
        @registered_user.send_email_notifications = true
        @registered_user.save
        @gold_user.send_email_notifications = true
        @gold_user.save
        @silver_user.send_email_notifications = true
        @silver_user.save
      end

      context "when the discussion is gold access class" do
        setup do
          new_request(@community, @community.owner)
          @theme = Theme.make(:community => @community, :access_classes => [@gold])
          @body = Sham.paragraphs
          @title = Sham.word
          post :create, {:discussion => {:body => @body, :theme_id => @theme.id, :title => @title}}
        end

        should "only send emails to members that have access to the new discussion" do
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@gold_user.email) &&
            email.body =~ /#{@title}/
          end
        end
      end

      context "when the discusison is for any registered people" do
        setup do
          new_request(@community, @community.owner)
          @theme = Theme.make(:community => @community, :registered => true)
          @body = Sham.paragraphs
          @title = Sham.word
          post :create, {:discussion => {:body => @body, :theme_id => @theme.id, :title => @title}}
        end

        should "send emails to all subscribed members" do
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@registered_user.email) &&
            email.body =~ /#{@title}/
          end
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@gold_user.email) &&
            email.body =~ /#{@title}/
          end
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@silver_user.email) &&
            email.body =~ /#{@title}/
          end
        end
      end

      context "when the discusison is public" do
        setup do
          new_request(@community, @community.owner)
          @theme = Theme.make(:community => @community, :registered => false)
          @body = Sham.paragraphs
          @title = Sham.word
          post :create, {:discussion => {:body => @body, :theme_id => @theme.id, :title => @title}}
        end

        should "send emails to all subscribed members" do
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@registered_user.email) &&
            email.body =~ /#{@title}/
          end
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@gold_user.email) &&
            email.body =~ /#{@title}/
          end
          assert_sent_email do |email|
            email.from.first =~ /#{@community.host}/ &&
            email.to.include?(@silver_user.email) &&
            email.body =~ /#{@title}/
          end
        end
      end
    end

    context "on GET to :show" do
      context "with a public discussion" do
        setup do
          @discussion = Discussion.make(:community => @community)
        end

        should "allow access to public" do
          new_request(@community, nil)
          get :show, { :id => @discussion.id }
          assert_response :success
        end

        should "allow access to registered user" do
          new_request(@community, @registered_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end

        should "allow access to gold user" do
          new_request(@community, @gold_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end

        should "allow access to silver user" do
          new_request(@community, @silver_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end
      end

      context "with a registered discussion" do
        setup do
          @theme = Theme.make(:community => @community, :registered => true)
          @discussion = Discussion.make(:community => @community, :theme => @theme)
        end

        should "not allow access to public" do
          new_request(@community, nil)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end

        should "allow access to registered user" do
          new_request(@community, @registered_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end

        should "allow access to gold user" do
          new_request(@community, @gold_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end

        should "allow access to silver user" do
          new_request(@community, @silver_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end
      end

      context "with a gold discussion" do
        setup do
          @theme = Theme.make(:community => @community, :registered => true, :access_classes => [@gold])
          @discussion = Discussion.make(:community => @community, :theme => @theme)
        end

        should "not allow access to public" do
          new_request(@community, nil)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end

        should "not allow access to registered user" do
          new_request(@community, @registered_user)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end

        should "allow access to gold user" do
          new_request(@community, @gold_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end

        should "not access to silver user" do
          new_request(@community, @silver_user)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end
      end

      context "with a silver discussion" do
        setup do
          @theme = Theme.make(:community => @community, :registered => true, :access_classes => [@silver])
          @discussion = Discussion.make(:community => @community, :theme => @theme)
        end

        should "not allow access to public" do
          new_request(@community, nil)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end

        should "not allow access to registered user" do
          new_request(@community, @registered_user)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end

        should "not access to gold user" do
          new_request(@community, @gold_user)
          get :show, { :id => @discussion.id }
          assert_response :redirect
        end

        should "allow access to silver user" do
          new_request(@community, @silver_user)
          get :show, { :id => @discussion.id }
          assert_response :success
        end
      end
    end

    context "on GET to :index" do
      setup do
        @public_discussion = Discussion.make(:community => @community, :theme => @public_theme)
        @registered_discussion = Discussion.make(:community => @community, :theme => @registered_theme)
        @gold_discussion = Discussion.make(:community => @community, :theme => @gold_theme)
        @silver_discussion = Discussion.make(:community => @community, :theme => @silver_theme)
      end

      context "when not logged in" do
        setup do
          new_request(@community, nil)
        end

        context "with no theme" do
          setup do
            get :index
          end

          should "not see create discussion link" do
            assert_select 'div#create_discussion', false
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with public theme" do
          setup do
            get :index, :theme_id => @public_theme.id
          end

          should "not see create discussion link" do
            assert_select 'div#create_discussion', false
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with registered theme" do
          setup do
            get :index, :theme_id => @registered_theme.id
          end

          should_redirect_to "login_url"
        end

        context "with gold theme" do
          setup do
            get :index, :theme_id => @gold_theme.id
          end

          should_redirect_to "login_url"
        end

        context "with silver theme" do
          setup do
            get :index, :theme_id => @silver_theme.id
          end

          should_redirect_to "login_url"
        end
      end

      context "when logged in as registered user" do
        setup do
          new_request(@community, @registered_user)
        end

        context "with no theme" do
          setup do
            get :index
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "see registered discussion" do
            assert_equal(true, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with public theme" do
          setup do
            get :index, :theme_id => @public_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with registered theme" do
          setup do
            get :index, :theme_id => @registered_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "not see public discussion" do
            assert_equal(false, assigns(:discussions).include?(@public_discussion))
          end

          should "see registered discussion" do
            assert_equal(true, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with gold theme" do
          setup do
            get :index, :theme_id => @gold_theme.id
          end

          should_redirect_to "upgrade_url"
        end

        context "with silver theme" do
          setup do
            get :index, :theme_id => @silver_theme.id
          end

          should_redirect_to "upgrade_url"
        end
      end


      context "when logged in as gold user" do
        setup do
          new_request(@community, @gold_user)
        end

        context "with no theme" do
          setup do
            get :index
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "see registered discussion" do
            assert_equal(true, assigns(:discussions).include?(@registered_discussion))
          end

          should "see gold discussion" do
            assert_equal(true, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with public theme" do
          setup do
            get :index, :theme_id => @public_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with registered theme" do
          setup do
            get :index, :theme_id => @registered_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "not see public discussion" do
            assert_equal(false, assigns(:discussions).include?(@public_discussion))
          end

          should "see registered discussion" do
            assert_equal(true, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with gold theme" do
          setup do
            get :index, :theme_id => @gold_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "not see public discussion" do
            assert_equal(false, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "see gold discussion" do
            assert_equal(true, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with silver theme" do
          setup do
            get :index, :theme_id => @silver_theme.id
          end

          should_redirect_to "upgrade_url"
        end
      end

      context "when logged in as silver user" do
        setup do
          new_request(@community, @silver_user)
        end

        context "with no theme" do
          setup do
            get :index
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "see registered discussion" do
            assert_equal(true, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "see silver discussion" do
            assert_equal(true, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with public theme" do
          setup do
            get :index, :theme_id => @public_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "see public discussion" do
            assert_equal(true, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with registered theme" do
          setup do
            get :index, :theme_id => @registered_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "not see public discussion" do
            assert_equal(false, assigns(:discussions).include?(@public_discussion))
          end

          should "see registered discussion" do
            assert_equal(true, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "not see silver discussion" do
            assert_equal(false, assigns(:discussions).include?(@silver_discussion))
          end
        end

        context "with gold theme" do
          setup do
            get :index, :theme_id => @gold_theme.id
          end

          should_redirect_to "upgrade_url"
        end

        context "with silver theme" do
          setup do
            get :index, :theme_id => @silver_theme.id
          end

          should "see create discussion link" do
            assert_select 'div#create_discussion', true
          end

          should "not see public discussion" do
            assert_equal(false, assigns(:discussions).include?(@public_discussion))
          end

          should "not see registered discussion" do
            assert_equal(false, assigns(:discussions).include?(@registered_discussion))
          end

          should "not see gold discussion" do
            assert_equal(false, assigns(:discussions).include?(@gold_discussion))
          end

          should "see silver discussion" do
            assert_equal(true, assigns(:discussions).include?(@silver_discussion))
          end
        end
      end
    end

    context "on GET to :new" do
      context "when not logged in" do
        setup do
          new_request(@community, nil)
          get :new
        end

        should_redirect_to "login_url"
      end

      context "when logged in as registered user" do
        setup do
          new_request(@community, @registered_user)
          get :new
        end

        should_respond_with :success

        should "include public theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@public_theme))
        end

        should "include registered theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@registered_theme))
        end

        should "not include gold theme" do
          assert_equal(false, assigns(:accessible_themes).include?(@gold_theme))
        end

        should "not include silver theme" do
          assert_equal(false, assigns(:accessible_themes).include?(@silver_theme))
        end
      end

      context "when logged in as gold user" do
        setup do
          new_request(@community, @gold_user)
          get :new
        end

        should_respond_with :success

        should "include public theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@public_theme))
        end

        should "include registered theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@registered_theme))
        end

        should "include gold theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@gold_theme))
        end

        should "not include silver theme" do
          assert_equal(false, assigns(:accessible_themes).include?(@silver_theme))
        end
      end

      context "when logged in as silver user" do
        setup do
          new_request(@community, @silver_user)
          get :new
        end

        should_respond_with :success

        should "include public theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@public_theme))
        end

        should "include registered theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@registered_theme))
        end

        should "not include gold theme" do
          assert_equal(false, assigns(:accessible_themes).include?(@gold_theme))
        end

        should "include silver theme" do
          assert_equal(true, assigns(:accessible_themes).include?(@silver_theme))
        end
      end
    end
  end
end
