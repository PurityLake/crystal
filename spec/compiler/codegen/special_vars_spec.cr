require "../../spec_helper"

describe "Codegen: special vars" do
  ["$~", "$?"].each do |name|
    it "codegens #{name}" do
      run(%(
        class Object; def not_nil!; self; end; end

        def foo(z)
          #{name} = "hey"
        end

        foo(2)
        #{name}
        )).to_string.should eq("hey")
    end

    it "codegens #{name} with nilable (1)" do
      run(%(
        require "prelude"

        def foo
          if 1 == 2
            #{name} = "foo"
          end
        end

        foo

        begin
          #{name}
        rescue ex
          "ouch"
        end
        )).to_string.should eq("ouch")
    end

    it "codegens #{name} with nilable (2)" do
      run(%(
        require "prelude"

        def foo
          if 1 == 1
            #{name} = "foo"
          end
        end

        foo

        begin
          #{name}
        rescue ex
          "ouch"
        end
        )).to_string.should eq("foo")
    end
  end

  it "codegens $~ two levels" do
    run(%(
      class Object; def not_nil!; self; end; end

      def foo
        $? = "hey"
      end

      def bar
        $? = foo
        $?
      end

      bar
      $?
      )).to_string.should eq("hey")
  end

  it "works lazily" do
    run(%(
      require "prelude"

      class Foo
        getter string

        def initialize(@string)
        end
      end

      def bar(&block : Foo -> _)
        block
      end

      block = bar do |foo|
        case foo.string
        when /foo-(.+)/
          $1
        else
          "baz"
        end
      end
      block.call(Foo.new("foo-bar"))
      )).to_string.should eq("bar")
  end
end
