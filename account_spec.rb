require "rspec"

require_relative "account"

describe Account do

  let(:account_number) { "1234567899" }
  let(:account) { Account.new(account_number) }

  describe "#initialize" do
    context "with valid input" do
      it "doesn't raise an error" do
        expect(account).to_not raise_error()
      end
    end

    context "with invalid input" do 
      it "raises an error" do
        expect { Account.new("123") }.to raise_error(InvalidAccountNumberError)
      end

      it "requires string input" do
        expect { Account.new(1234567899) }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#transactions" do
    it "initializes with one transaction" do
      expect(account.transactions.length).to eq 1
    end

    it "stores transactions in array" do 
      expect(account.transactions).to be_instance_of Array
    end
  end

  describe "#balance" do
    it "returns an integer" do 
      expect(account.balance).to be_a Integer
    end
  end

  describe "#acct_number" do
    it 'returns a string' do
      expect(account.acct_number).to be_a String
    end

    it 'should have length of 10' do
      expect(account.acct_number.length).to eq 10
    end

    it 'should only show the last four digits' do
      expect(account.acct_number).to match(/\*{6}\d{4}/)
    end
  end

  describe "deposit!" do
    it 'raises error if deposit is less than 0' do
      expect{account.deposit!(-1)}.to raise_error(NegativeDepositError)
    end

    it 'calls the add transaction methos' do
      account.should receive(:add_transaction).with(10)
      account.deposit!(10)
    end

    it 'adds a transaction' do
      expect{account.deposit!(1)}.to change{account.transactions.length}.from(1).to(2)
    end

    it 'calls balance method' do
      account.stub(:balance).and_return(0)
      account.should receive(:balance)
      account.deposit!(10)
    end
  end

  describe "#withdraw!" do
    context 'with sufficient balance' do
      before do
        @sufficient_account = Account.new('1111111111', 100)
      end

      it 'adds a transaction' do
        expect{@sufficient_account.withdraw!(-10)}.to change{@sufficient_account.transactions.length}.by(1)
      end

      it 'does not raise an overdraft error' do
        expect{@sufficient_account.withdraw!(-10)}.to_not raise_error()
      end

      it 'changes the balance by the withrawn amount' do
        expect{@sufficient_account.withdraw!(-10)}.to change{@sufficient_account.balance}.by(-10)
      end

      it 'changes a postive parameter to a negative withdrawal' do
        expect{@sufficient_account.withdraw!(10)}.to change{@sufficient_account.balance}.by(-10)
      end
    end

    context 'with insufficient balance' do
      before do
        @insufficient_account = Account.new('1111111111', 0)
      end

      it 'does raise an overdraft error' do
        expect{@insufficient_account.withdraw!(10)}.to raise_error(OverdraftError)
      end
    end
  end
end
