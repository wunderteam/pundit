require "spec_helper"

describe Pundit do
  let(:user) { double }
  let(:post) { Post.new(user) }
  let(:comment) { Comment.new }
  let(:article) { Article.new }
  let(:controller) { Controller.new(user, { :action => 'update' }) }
  let(:artificial_blog) { ArtificialBlog.new }
  let(:article_tag) { ArticleTag.new }

  describe ".policy" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy(user, post)
      expect(policy.user).to eq user
      expect(policy.post).to eq post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy(user, comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy(user, Post)
      expect(policy.user).to eq user
      expect(policy.post).to eq Post
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy(user, Comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq Comment
    end

    it "returns nil if the given policy can't be found" do
      expect(Pundit.policy(user, article)).to be_nil
      expect(Pundit.policy(user, Article)).to be_nil
    end

    describe "with .policy_class set on the model" do
      it "returns an instantiated policy given a plain model instance" do
        policy = Pundit.policy(user, artificial_blog)
        expect(policy.user).to eq user
        expect(policy.blog).to eq artificial_blog
      end

      it "returns an instantiated policy given a plain model class" do
        policy = Pundit.policy(user, ArtificialBlog)
        expect(policy.user).to eq user
        expect(policy.blog).to eq ArtificialBlog
      end

      it "returns an instantiated policy given a plain model instance providing an anonymous class" do
        policy = Pundit.policy(user, article_tag)
        expect(policy.user).to eq user
        expect(policy.tag).to eq article_tag
      end

      it "returns an instantiated policy given a plain model class providing an anonymous class" do
        policy = Pundit.policy(user, ArticleTag)
        expect(policy.user).to eq user
        expect(policy.tag).to eq ArticleTag
      end

      it "returns an instantiated policy given a symbol" do
        policy = Pundit.policy(user, :dashboard)
        expect(policy.class).to eq DashboardPolicy
        expect(policy.user).to eq user
        expect(policy.dashboard).to eq :dashboard
      end
    end
  end

  describe ".policy!" do
    it "returns an instantiated policy given a plain model instance" do
      policy = Pundit.policy!(user, post)
      expect(policy.user).to eq user
      expect(policy.post).to eq post
    end

    it "returns an instantiated policy given an active model instance" do
      policy = Pundit.policy!(user, comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq comment
    end

    it "returns an instantiated policy given a plain model class" do
      policy = Pundit.policy!(user, Post)
      expect(policy.user).to eq user
      expect(policy.post).to eq Post
    end

    it "returns an instantiated policy given an active model class" do
      policy = Pundit.policy!(user, Comment)
      expect(policy.user).to eq user
      expect(policy.comment).to eq Comment
    end

    it "returns an instantiated policy given a symbol" do
      policy = Pundit.policy!(user, :dashboard)
      expect(policy.class).to eq DashboardPolicy
      expect(policy.user).to eq user
      expect(policy.dashboard).to eq :dashboard
    end

    it "throws an exception if the given policy can't be found" do
      expect { Pundit.policy!(user, article) }.to raise_error(Pundit::PolicyMissing)
      expect { Pundit.policy!(user, Article) }.to raise_error(Pundit::PolicyMissing)
    end
  end

  describe "#authorize" do
    it "infers the policy name and authorized based on it" do
      expect(controller.authorize(post)).to be_truthy
    end

    it "can be given a different permission to check" do
      expect(controller.authorize(post, :show?)).to be_truthy
      expect { controller.authorize(post, :destroy?) }.to raise_error(Pundit::NotAuthorized)
    end

    it "works with anonymous class policies" do
      expect(controller.authorize(article_tag, :show?)).to be_truthy
      expect { controller.authorize(article_tag, :destroy?) }.to raise_error(Pundit::NotAuthorized)
    end

    it "raises an error when the permission check fails" do
      expect { controller.authorize(Post.new) }.to raise_error(Pundit::NotAuthorized)
    end

    it "raises an error with a query and action" do
      expect { controller.authorize(post, :destroy?) }.to raise_error do |error|
        expect(error.query).to eq :destroy?
        expect(error.record).to eq post
        expect(error.policy).to eq controller.policy(post)
      end
    end
  end

  describe "#pundit_user" do
    it 'returns the same thing as current_user' do
      expect(controller.pundit_user).to eq controller.current_user
    end
  end

  describe ".policy" do
    it "returns an instantiated policy" do
      policy = controller.policy(post)
      expect(policy.user).to eq user
      expect(policy.post).to eq post
    end

    it "throws an exception if the given policy can't be found" do
      expect { controller.policy(article) }.to raise_error(Pundit::PolicyMissing)
    end

    it "allows policy to be injected" do
      new_policy = OpenStruct.new
      controller.policy = new_policy

      expect(controller.policy(post)).to eq new_policy
    end
  end
end
