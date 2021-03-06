require 'spec_helper'

describe Cocoon do
  class TestClass < ActionView::Base

  end

  subject {TestClass.new}

  it { should respond_to(:link_to_add_association) }
  it { should respond_to(:link_to_remove_association) }

  context "link_to_add_association" do
    before(:each) do
      @tester = TestClass.new
      @post = Post.new
      @form_obj = stub(:object => @post)
      @tester.stub(:render_association).and_return('form<tag>')
    end

    context "without a block" do
      it "accepts a name" do
        result = @tester.link_to_add_association('add something', @form_obj, :comments)
        result.to_s.should == '<a href="#" class="add_fields" data-association="comment" data-associations="comments" data-template="form&lt;tag&gt;">add something</a>'
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_add_association('add something', @form_obj, :comments, {:class => 'something silly'})
        result.to_s.should == '<a href="#" class="something silly add_fields" data-association="comment" data-associations="comments" data-template="form&lt;tag&gt;">add something</a>'
      end
    end

    context "with a block" do
      it "the block gives the link text" do
        result = @tester.link_to_add_association(@form_obj, :comments) do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="add_fields" data-association="comment" data-associations="comments" data-template="form&lt;tag&gt;">some long name</a>'
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_add_association(@form_obj, :comments, {:class => 'floppy disk'}) do
          "some long name"
        end
        result.to_s.should == '<a href="#" class="floppy disk add_fields" data-association="comment" data-associations="comments" data-template="form&lt;tag&gt;">some long name</a>'
      end

    end

    context "with an irregular plural" do
      it "uses the correct plural" do
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association="person" data-associations="people" data-template="form&lt;tag&gt;">add something</a>'
      end
    end

    it "tttt" do
      @post.class.reflect_on_association(:people).klass.new.should be_a(Person)
    end

    context "with extra render-options for rendering the child relation" do
      it "uses the correct plural" do
        @tester.should_receive(:render_association).with(:people, @form_obj, anything, {:wrapper => 'inline'}, nil)
        result = @tester.link_to_add_association('add something', @form_obj, :people, :render_options => {:wrapper => 'inline'})
        result.to_s.should == '<a href="#" class="add_fields" data-association="person" data-associations="people" data-template="form&lt;tag&gt;">add something</a>'
      end
    end

    context "when using formtastic" do
      before(:each) do
        @tester.unstub(:render_association)
        @form_obj.stub(:semantic_fields_for).and_return('form<tagzzz>')
      end
      it "calls semantic_fields_for and not fields_for" do
        @form_obj.should_receive(:semantic_fields_for)
        @form_obj.should_receive(:fields_for).never
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association="person" data-associations="people" data-template="form&lt;tagzzz&gt;">add something</a>'

      end
    end
    context "when using simple_form" do
      before(:each) do
        @tester.unstub(:render_association)
        @form_obj.stub(:simple_fields_for).and_return('form<tagxxx>')
      end
      it "responds_to :simple_fields_for" do
        @form_obj.should respond_to(:simple_fields_for)
      end
      it "calls simple_fields_for and not fields_for" do
        @form_obj.should_receive(:simple_fields_for)
        @form_obj.should_receive(:fields_for).never
        result = @tester.link_to_add_association('add something', @form_obj, :people)
        result.to_s.should == '<a href="#" class="add_fields" data-association="person" data-associations="people" data-template="form&lt;tagxxx&gt;">add something</a>'

      end
    end

  end

  context "link_to_remove_association" do
    before(:each) do
      @tester = TestClass.new
      @post = Post.new
      @form_obj = stub(:object => @post, :object_name => @post.class.name)
    end

    context "without a block" do
      it "accepts a name" do
        result = @tester.link_to_remove_association('remove something', @form_obj)
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"remove_fields dynamic\">remove something</a>"
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_remove_association('remove something', @form_obj, {:class => 'add_some_class', :'data-something' => 'bla'})
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"add_some_class remove_fields dynamic\" data-something=\"bla\">remove something</a>"
      end

    end

    context "with a block" do
      it "the block gives the name" do
        result = @tester.link_to_remove_association(@form_obj) do
          "remove some long name"
        end
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"remove_fields dynamic\">remove some long name</a>"
      end

      it "accepts html options and pass them to link_to" do
        result = @tester.link_to_remove_association(@form_obj, {:class => 'add_some_class', :'data-something' => 'bla'}) do
          "remove some long name"
        end
        result.to_s.should == "<input id=\"Post__destroy\" name=\"Post[_destroy]\" type=\"hidden\" /><a href=\"#\" class=\"add_some_class remove_fields dynamic\" data-something=\"bla\">remove some long name</a>"
      end
    end

    context "association with conditions" do
      it "should create correct association" do
        result = @tester.create_object(@form_obj, :admin_comments)
        result.author.should == "Admin"
      end
    end

    context "setup_partial" do
      it "generates the default partial name if no partial given" do
        result = @tester.setup_partial(nil, :admin_comments)
        result.should == "admin_comment_fields"
      end
      it "uses the given partial name" do
        result = @tester.setup_partial("comment_fields", :admin_comments)
        result.should == "comment_fields"
      end
    end
  end

end
