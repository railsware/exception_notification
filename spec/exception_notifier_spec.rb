require 'spec_helper'

describe ExceptionNotifier do

  describe "with 'with' class method" do
    before(:each) do
      begin 1/0
      rescue => e
        @exception = e
      end
    end

    it "should NOT deliver background notification if block does not raise error" do
      ExceptionNotifier::Notifier.should_not_receive(:background_exception_notification)

      ExceptionNotifier.with { 1/1 }
    end
    
    it "should deliver background notification if block raises error" do
      @mailer_mock = mock("mailer mock")
      @mailer_mock.should_receive(:deliver)
      ExceptionNotifier::Notifier.should_receive(:background_exception_notification).
        with(@exception, {}).and_return(@mailer_mock)

      lambda { ExceptionNotifier.with { raise @exception } }.should raise_error(@exception)
    end
    
    it "should pass options to background_exception_notification method" do
      @mailer_mock = mock("mailer mock")
      @mailer_mock.should_receive(:deliver)
      ExceptionNotifier::Notifier.should_receive(:background_exception_notification).
        with(@exception, { :name => "Daemon" }).and_return(@mailer_mock)

      lambda { ExceptionNotifier.with(:name => "Daemon") { raise @exception } }.should raise_error(@exception)
    end

  end
end
