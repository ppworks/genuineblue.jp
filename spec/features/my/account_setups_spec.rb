require "spec_helper"

describe 'My/Setups' do
  let(:user) { create(:user, :with_unread) }

  describe '/にアクセスする' do
    before do
      sign_in(user)
      visit root_path
    end
    it 'セットアップ画面に飛ぶ' do
      expect(current_path).to eq my_account_setup_path
    end

    describe '情報を入力する' do
      let(:new_user) { build(:user) }
      before do
        find('#user_name').set(new_user.name)
        find("#edit_user_#{user.id} input[type=submit]").click()
      end
      it 'ヘッダにユーザー名が表示されること' do
        within '.navbar' do
          expect(page).to have_content(new_user.name)
        end
      end

      describe '/にアクセスする' do
        before do
          visit root_path
        end
        it 'セットアップ画面に飛ぶない' do
          expect(current_path).to eq root_path
        end
      end
    end
  end
end
