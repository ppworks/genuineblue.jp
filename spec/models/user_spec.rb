require 'spec_helper'

describe User do
  let(:connection) { build(:connection) }
  let(:user) { create(:user, connections: [connection]) }
  let(:valid_auth_hash) {
    {
      'provider' => 'developer',
      'uid' => '123456',
      'info' => {
        'nickname' => 'ppworks',
        'name' => 'PP works',
        'image' => 'http://a0.twimg.com/profile_images/2900491556/9d2bf873770958647f18b8e61af31f1a_normal.png'
      },
      'credentials' => {
        'token' => '123445678-AbeafjabutWjfav932m38e3TTabbbbbk',
        'secret' => 'UzOc15tGx8AMYLOX5dcZ2UQTEwe6LiVysdoyhiKlaw'
      }
    }
  }

  describe 'Create user' do
    subject { user }
    it { expect(subject).to be_instance_of(User) }
  end

  describe 'relations' do
    it { should have_many(:connections) }
  end

  describe 'メールアドレス、パスワード空のユーザー登録' do
    let(:user) { build(:user, email: nil, password: nil) }
    context 'OauthSignupableを実装していない' do
      it 'ユーザーが増えない' do
        expect {
          user.save
        }.to change(User, :count).by(0)
      end
    end

    context 'OauthSignupableを実装している' do
      it 'ユーザーが1人増えること' do
        expect {
          user.extend OauthSignupable
          user.save
        }.to change(User, :count).by(1)
      end
    end
  end

  describe '.authentication' do
    let(:auth_hash) { nil }
    let(:current_user) { nil }
    subject { User.authentication(auth_hash, current_user) }

    context 'auth_hashがない' do
      it { should be_nil }
    end

    context 'auth_hashがある' do
      let(:auth_hash) { valid_auth_hash }

      context 'current_userがいる(ログイン中の場合)' do
        let(:current_user) { user }
        context 'connectionがある' do
          let(:connection) { build(:connection) }
          before do
            user.connections << connection
          end
          it { should eq user }
          it { should be_instance_of User }
        end

        context 'connectionがない' do
          it { should eq user }
          it { should be_instance_of User }
        end
      end

      context 'current_userがいない(未ログインの場合)' do
        context 'connectionがある' do
          before do
            connection = user.connections.last
            connection.uid = auth_hash['uid']
            connection.save
          end
          it { should eq user }
          it { should be_instance_of User }
        end

        context 'connectionがない' do
          let!(:new_user) { build(:user) }
          before do
            User.stub(:new).and_return(new_user)
          end
          it { should eq new_user }
          it { should be_instance_of User }
        end
      end
    end
  end

  describe '#me?' do
    subject { user.me?(whoami) }

    context 'me' do
      let(:whoami) { user }
      it { should be_true }
    end

    context 'other' do
      let(:whoami) { create(:user) }
      it { should be_false }
    end
  end
end
