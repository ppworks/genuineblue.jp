require "spec_helper"

describe 'My/Byebyes' do
  let(:user) { create(:user) }

  describe '退会画面にアクセスする', :js do
    before do
      sign_in(user)
      visit my_account_byebye_path
    end

    describe '退会する' do
      before do
        find('.withdraw-btn').click()
      end
      it '退会メッセージが表示されること' do
        expect(page).to have_content(I18n.t('devise.registrations.destroyed'))
      end
    end
  end
end
