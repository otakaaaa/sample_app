module SessionsHelper
    # ログイン
    def log_in(user)
        session[:user_id] = user.id
        # セッションリプレイ攻撃から保護する
        # 詳しくは https://bit.ly/33UvK0w を参照
        session[:session_token] = user.session_token
    end 

    # 永続セッションのためにユーザーをデータベースに記憶する
    def remember(user)
        user.remember
        cookies.permanent.encrypted[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # 記憶トークンcookieに対応するユーザーを返す
    # 現在ログイン中のユーザーを返す（いる場合）
    def current_user
        if (user_id = session[:user_id])
            @user = User.find_by(id: user_id)
            if @user && session[:session_token] == @user.remember_token
                @current_user = @user
            end
            @current_user ||= User.find_by(id: :user_id)
        elsif (user_id = cookies.encrypted[:user_id])
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    # ログインしていたらtrue, それ以外はfalse
    def logged_in?
        !current_user.nil?
    end

    # 永続的セッションを破棄する
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # ログアウト
    def log_out
        forget(current_user)
        reset_session
        @current_user = nil
    end
end
