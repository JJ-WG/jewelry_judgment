# encoding: utf-8

#
#= Userモデルクラス
#
# Created:: 2012/10/5
#
class User < ActiveRecord::Base
  # アクセサ定義
  attr_accessible :password, :password_confirmation, :user_rank_cd,
      :crypted_password, :current_login_at, :deleted_at, :last_login_at,
      :login, :login_count, :name, :name_ruby, :password_salt,
      :persistence_token, :section_id, :unit_price, :occupation_id,
      :official_position, :home_phome_no, :mobile_phone_no, :mail_address1,
      :mail_address2, :mail_address3, :deleted, :user_code, :now_password,
      :unit_prices_attributes
  attr_accessor :unit_price_start_date, :unit_price_unit_price
  
  # Authlogicのユーザ情報として使用するための宣言
  acts_as_authentic
  
  # アソシエーション
  belongs_to :section
  belongs_to :occupation
  has_many :sch_members
  has_many :results
  has_many :csv_results
  has_many :csv_sch_members
  has_many :expenses
  has_many :notices
  has_many :prj_members
  has_many :projects, :through => :prj_members
  has_many :unit_prices
  accepts_nested_attributes_for :unit_prices
  
  # バリデーション設定
=begin
  validates(:user_rank_cd, :presence => true)
  validates(:official_position, :length => {:maximum => 20})
  validates(:name, :presence => true, :length => {:maximum => 20})
  validates(:name_ruby, :presence => true, :length => {:maximum => 40})
  validates(:user_code, :presence => true, :length => {:maximum => 10})
  validates(:home_phome_no, :length => {:maximum => 20})
  validates(:mobile_phone_no, :length => {:maximum => 20})
  validates(:mail_address1, :presence => true, :length => {:maximum => 40})
  validates(:mail_address2, :length => {:maximum => 40})
  validates(:mail_address3, :length => {:maximum => 40})
  #validates(:now_password, :presence => true,
  #    :length => {:minimum => 6, :maximum => 20})
  #validate :is_valid
=end
  
  # スコープ定義
  scope :deleted, where(:deleted => true)
  scope :alive, where(:deleted => false)
  scope :list_order, order('users.deleted, users.name_ruby')

  # 以下、プライベートメソッド
private
  ##
  # バリデーションメソッド
  # 
  def is_valid
    
  end

  # 以下、パブリックメソッド
public
  ##
  # 登録入力チェック
  # 
  def is_valid?(action = 'create')   
    # ユーザー区分
    if self.user_rank_cd.blank?
      errors.add(:user_rank_cd, 'を入力してください。')
    end
    
    # 役職
    if self.official_position.present?
      if self.official_position.length > 20
        errors.add(:official_position, 'は20文字以内で入力してください。')
      end
    end
    
    # 氏名
    if self.name.blank?
      errors.add(:name, 'を入力してください。')
    else
      if self.name.length > 20
        errors.add(:name, 'は20文字以内で入力してください。')
      end
    end
    
    # フリガナ
    if self.name_ruby.blank?
      errors.add(:name_ruby, 'を入力してください。')
    else
      if self.name_ruby.length > 40
        errors.add(:name_ruby, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-zァ-ヶー 　]+$/ =~ self.name_ruby)
        errors.add(:name_ruby, 'は半角英数字、または半角スペース、または全角カタカナ、または全角スペースを入力してください。')
      end
    end
    
    # ユーザーコード
    if self.user_code.blank?
      errors.add(:user_code, 'を入力してください。')
    else
      if self.user_code.length > 10
        errors.add(:user_code, 'は10文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z]+$/ =~ self.user_code)
        errors.add(:user_code, 'は半角英数字を入力してください。')
      end
      
      if User.exist_user_code(self.id, self.user_code)
        errors.add(:user_code, 'が他ユーザーで使用済みです。')
      end
    end
    
    # 自宅電話番号
    if self.home_phome_no.present?
      if self.home_phome_no.length > 20
        errors.add(:home_phome_no, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9-]+$/ =~ self.home_phome_no)
        errors.add(:home_phome_no, 'は半角数字、またはハイフンを入力してください。')
      end
    end
    
    # 携帯番号
    if self.mobile_phone_no.present?
      if self.mobile_phone_no.length > 20
        errors.add(:mobile_phone_no, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9-]+$/ =~ self.mobile_phone_no)
        errors.add(:mobile_phone_no, 'は半角数字、またはハイフンを入力してください。')
      end
    end
    
    # メールアドレス1
    if self.mail_address1.blank?
      errors.add(:mail_address1, 'を入力してください。')
    else
      if self.mail_address1.length > 40
        errors.add(:mail_address1, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ self.mail_address1)
        errors.add(:mail_address1, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # メールアドレス2
    if self.mail_address2.present?
      if self.mail_address2.length > 40
        errors.add(:mail_address2, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ self.mail_address2)
        errors.add(:mail_address2, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # メールアドレス3
    if self.mail_address3.present?
      if self.mail_address3.length > 40
        errors.add(:mail_address3, 'は40文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ self.mail_address3)
        errors.add(:mail_address3, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # ログインID
    if self.login.blank?
      errors.add(:login, 'を入力してください。')
    else
      if self.login.length > 20
        errors.add(:login, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ self.login)
        errors.add(:login, 'は半角英数字、または記号を入力してください。')
      end
      
      if User.exist_login(self.id, self.login)
        errors.add(:login, 'が他ユーザーで使用済みです。')
      end
    end
    
    # パスワード
    if self.password.blank?
      if action == 'create'
        errors.add(:password, 'を入力してください。')
      end
    else
      if self.password.length < 6
        errors.add(:password, 'は6文字以上で入力してください。')
      end
      
      if self.password.length > 20
        errors.add(:password, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ self.password)
        errors.add(:password, 'は半角英数字、または記号を入力してください。')
      end
    end
    
    # パスワード（再入力）
    if self.password_confirmation.blank?
      if action == 'create' || self.password.present?
        errors.add(:password_confirmation, 'を入力してください。')
      end
    else
      if self.password_confirmation.length < 6
        errors.add(:password_confirmation, 'は6文字以上で入力してください。')
      end
      
      if self.password_confirmation.length > 20
        errors.add(:password_confirmation, 'は20文字以内で入力してください。')
      end
      
      if !(/^[0-9A-Za-z!"#\$%&'()*+,-.\/;;<=>?@_]+$/ =~ self.password_confirmation)
        errors.add(:password_confirmation, 'は半角英数字、または記号を入力してください。')
      end
      
      if self.password != self.password_confirmation
        errors.add(:password, 'が一致しません。')
      end
    end
    
    if errors.blank?
      return true
    else
      return false
    end
  end
  
  ##
  # ユーザーコードが他データで使用済みか
  # 
  # 戻り値::
  #   true:使用済み / false:未使用
  #
  def self.exist_user_code(id, user_code)
    if id.present?
      count = User.count(:user_code,
          :conditions => ['id != ? AND user_code = ?', id, user_code])
    else
      count = User.count(:user_code,
          :conditions => ['user_code = ?', user_code])
    end
    return (count > 0)? true : false
  end
  
  ##
  # ログインIDが他データで使用済みか
  # （英字の大文字小文字を区別しない）
  # 
  # 戻り値::
  #   true:使用済み / false:未使用
  #
  def self.exist_login(id, login)
    if id.present?
      count = User.count(:login,
          :conditions => ['id != ? AND LOWER(login) = ?', id, login.downcase])
    else
      count = User.count(:login,
          :conditions => ['LOWER(login) = ?', login.downcase])
    end
    return (count > 0)? true : false
  end
    
  ##
  # ユーザーリストを取得する
  # リストには論理削除されたユーザーを含む
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :include_deleted_user
  #       リストに論理削除されたユーザを含めるかどうか(true/false)
  #       省略した場合、論理削除されたユーザを含める
  #    - :include_parttimer_user
  #       リストにユーザー区分が外注・アルバイトのユーザを含めるかどうか(true/false)
  #       省略した場合、外注・アルバイトのユーザを含める
  # 戻り値::
  #   ユーザーリスト
  #
  def self.users_list(option = {})
    return User
        .select('name, id')
        .where((option[:include_deleted_user].nil? || option[:include_deleted_user]) ?
            nil : {:deleted => false})
        .where((option[:include_parttimer_user].nil? || option[:include_parttimer_user]) ?
            nil : 'user_rank_cd != ' + USER_RANK_CODE[:parttimer].to_s)
        .list_order.collect{|s| [s.name, s.id]}
  end
  
  ##
  # 指定されたユーザーがユーザーに無い場合、
  # ユーザーリストの最後にユーザーを追加する
  # 論理削除されたユーザーもリストに追加する
  # 
  # list::
  #   ユーザーリスト
  # user_id::
  #   リストに追加するユーザーのユーザーID 
  # 戻り値::
  #   ユーザーリスト
  #
  def self.add_to_list(list, user_id)
    if list.nil?
      list = []
    else
      list.each do |item|
        if item.last == user_id
          return list
        end
      end
    end
    return list << [self.get_name(user_id), user_id]
  end
  
  ##
  # ユーザーIDに対応するユーザーの氏名を取得する
  #
  # id::
  #   対象ユーザーのユーザーID
  # 戻り値::
  #   ユーザーの氏名を返す
  #
  def self.get_name(id)
    begin
      user = User.find(id)
      return user.name
    rescue
      return ''
    end
  end

  ##
  # ユーザーがプロジェクトリーダまたはプロジェクトマネージャーになっている
  # プロジェクトのメンバーリストを取得する。
  # メンバーリストにはユーザー自身を追加する。
  # リストには論理削除されたプロジェクトのメンバーを含まない。
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :include_deleted_user
  #       リストに論理削除されたユーザを含めるかどうか(true/false)
  # 戻り値::
  #   ユーザーリスト
  #
  def my_project_members_list(option = {})
    return User.select('users.id, users.name')
               .where('users.id = ? OR EXISTS('+
                      ' SELECT * FROM projects, prj_members' +
                      ' WHERE (projects.leader_id = ? OR projects.manager_id = ?)' +
                      ' AND projects.deleted=' + DB_FALSE_VALUE +
                      ' AND projects.id = prj_members.project_id' +
                      ' AND prj_members.user_id = users.id' +
                      ')', id, id, id)
               .where(option[:include_deleted_user] ? nil : {:deleted => false})
               .list_order
               .collect{|user| [user.name, user.id]}
  end
  
  ##
  # 自分と関係ありユーザリストを取得する。
  # 関係ありというのば、自分が管理しているプロジェクトのメンバ
  # と自分参加したプロジェクトのメンバ
  # メンバーリストにはユーザー自身を追加する。
  # リストには論理削除されたプロジェクトのメンバーを含まない。
  # 
  # 戻り値::
  #   ユーザーリスト
  #
  def my_relation_members_list
    project_ids = self.my_project_list({include_finished_project: true}).collect { |project| project[1] }
    user_ids = PrjMember.select(:user_id).where('project_id in (?)', project_ids).uniq.collect { |user| user.user_id }
    return User.select('users.id, users.name')
               .where('users.id in (?)', user_ids)
               .list_order
               .collect{|user| [user.name, user.id]}
  end

  ##
  # ユーザーがプロジェクトリーダまたはプロジェクトマネージャーまたは
  # プロジェクトメンバーになっているプロジェクトのリストを取得する。
  # リストには論理削除されたプロジェクトを含まない。
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :include_deleted_project
  #       リストに論理削除されたプロジェクトを含めるかどうか(true/false)
  #    - :include_finished_project
  #       リストに完了プロジェクトを含めるかどうか(true/false)
  # 戻り値::
  #   プロジェクトリスト
  #
  def my_project_list(option = {})
    return Project.select('projects.id, projects.name')
                  .where('projects.leader_id = ? OR projects.manager_id = ?' +
                         ' OR EXISTS(SELECT * FROM prj_members' +
                           ' WHERE (prj_members.project_id = projects.id' +
                           ' AND prj_members.user_id = ?))' , id, id, id)
                  .where(option[:include_deleted_project] ? nil
                    : {:deleted => false})
                  .where(option[:include_finished_project] ? nil
                    : {:status_cd => [STATUS_CODE[:preparation],
                                      STATUS_CODE[:progress]]})
                  .list_order
                  .collect{|project| [project.name, project.id]}
  end
  
  ##
  # 部署IDに該当するユーザリストを取得
  # 
  # section_id::
  #    部署ID
  # 戻り値::
  #   ユーザーリストを返す
  #   引数section_idが0の場合、部署IDがNULLのユーザリストを返す
  def self.user_list_by_section_id(section_id)
    if section_id == 0
      return User.where('section_id IS NULL AND deleted = ?', false)
                 .order('name_ruby ASC')
    else
      return User.where('section_id = ? AND deleted = ?', section_id, false)
                 .order('name_ruby ASC')
    end
  end

  ##
  # ユーザーがプロジェクトリーダまたはプロジェクトマネージャー
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :project_id
  #       指定のプロジェクトのリーダまたはマネージャーの判断
  # 戻り値::
  #   (true/false)
  #
  def project_manager?(option = {})
    return Project.where('projects.leader_id = ? OR projects.manager_id = ?', id, id)
                  .where(option[:project_id].blank? ? nil : {:id => option[:project_id]})
                  .length > 0
  end

  ##
  # ユーザーが参加した完了したプロジェクトを取得する。
  # 
  # option::
  #    ハッシュにより下記のオプションを指定可能
  #    - :start_at
  #       プロジェクトの完了年月日 >= 指定の年月日 条件で検索
  #    - :end_at
  #       プロジェクトの完了年月日 <= 指定の年月日 条件で検索
  # 戻り値::
  #   プロジェクトリスト
  #
  def my_finished_project_list(option = {})
    return Project.where('projects.leader_id = ? OR projects.manager_id = ?' +
                         ' OR EXISTS(SELECT * FROM prj_members' +
                           ' WHERE (prj_members.project_id = projects.id' +
                           ' AND prj_members.user_id = ?))' , id, id, id)
                  .where({:deleted => false, :status_cd => STATUS_CODE[:finished]})
                  .where(option[:start_at] ? ["finished_date >= ?", option[:start_at]] : nil)
                  .where(option[:end_at] ? ["finished_date <= ?", option[:end_at]] : nil)
                  .order('project_code ASC')
  end
end
