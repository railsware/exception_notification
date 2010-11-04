require 'spec_helper'

shared_examples_for "ExceptionNotifier::Notifier as mailer" do
  it "should have from field" do
    @mail.from.should == ['exception.notifier@default.com']
  end

  it "should have to field" do
    @mail.to.should == []
  end

  it "should have subject field" do
    @mail.subject.should == '[ERROR] [background] (ZeroDivisionError) "divided by 0"'
  end

end

describe ExceptionNotifier::Notifier do

  describe "with background_exception_notification method" do
    before(:each) do
      begin 1/0
      rescue => e
        @exception = e
      end
    end

    context "without options" do
      before(:each) do
        @mail = ExceptionNotifier::Notifier.background_exception_notification(@exception)
      end

      it_should_behave_like "ExceptionNotifier::Notifier as mailer"

      it "should not have attachments" do
        @mail.attachments.should == []
      end

      it "should contains backtrace in body" do
        @mail.body.should include(@exception.backtrace.first)
      end

      it "should NOT contain Data section" do
        @mail.body.should_not include('-'*31 + "\nData:\n" + '-'*31)
      end
    end


    context "with files option" do
      before(:each) do
        @filepath = File.expand_path('../../assets/rails.png', __FILE__)
        @mail = ExceptionNotifier::Notifier.background_exception_notification(@exception, { 
          :files => [ @filepath ]
        })
      end

      it_should_behave_like "ExceptionNotifier::Notifier as mailer"

      it "should consist from two parts" do
        @mail.parts.size.should == 2
      end

      it "should contain backtrace in first part" do
        @mail.parts[0].content_type.should == 'text/plain; charset=UTF-8'
        @mail.parts[0].body.should include(@exception.backtrace.first)
      end

      it "should contain image in second part" do
        File.open(@filepath, "r:ASCII-8BIT") { |f| @body = f.read }
        part = @mail.parts[1]
        part.should be_kind_of(Mail::Part)

        part.content_type.should == 'image/png; filename=rails.png'
        part.content_transfer_encoding.should == 'binary'
        part.body.should == @body
      end
    end

    context "with data option" do
      before(:each) do
        @data = {
          "user" => "Ivan Pupkin"
        } 
        @mail = ExceptionNotifier::Notifier.background_exception_notification(@exception, :data => @data)
      end

      it_should_behave_like "ExceptionNotifier::Notifier as mailer"

      it "should contain Data section" do
        @mail.body.should include('-'*31 + "\nData:\n" + '-'*31)
      end

      it "should contain data key and value in body" do
        @mail.body.should include("* user: Ivan Pupkin")
      end

    end

    context "with name option" do
      before(:each) do
        @mail = ExceptionNotifier::Notifier.background_exception_notification(@exception, :name => "Daemon")
      end

      it "should include option name in subject" do
        @mail.subject == '[ERROR] Daemon (ZeroDivisionError) "divided by 0")'
      end
    end

  end
end
