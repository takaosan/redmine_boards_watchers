  # def show_with_sp
  #   respond_to do |format|
  #     format.html {
  #       sort_init 'updated_on', 'desc'
  #       sort_update 'created_on' => "#{Message.table_name}.created_on",
  #                   'replies' => "#{Message.table_name}.replies_count",
  #                   'updated_on' => "#{Message.table_name}.updated_on"
  # 
  #       @topic_count = @board.topics.count
  #       @topic_pages = ActionController::Base::Paginator.new self, @topic_count, per_page_option, params['page']
  #     # VVK
  #       order_sort = ["#{Message.table_name}.sticky_priority DESC", sort_clause].compact.join(', ')
  #       if Rails::VERSION::MAJOR >= 3
  #         @topics =  @board.topics.reorder(order_sort).all(:include => [:author, {:last_reply => :author}],
  #                                       :limit  =>  @topic_pages.items_per_page,
  #                                       :offset =>  @topic_pages.current.offset)
  # 
  #       else
  #         @topics =  @board.topics.find :all, :order => order_sort,
  #                                       :include => [:author, {:last_reply => :author}],
  #                                       :limit  =>  @topic_pages.items_per_page,
  #                                       :offset =>  @topic_pages.current.offset
  #       end
  #     # VVK
  #       @message = Message.new(:board => @board)
  #       render :action => 'show', :layout => !request.xhr?
  #     }
  #     format.atom {
  #       @messages = @board.messages.find :all, :order => 'created_on DESC',
  #                                              :include => [:author, :board],
  #                                              :limit => Setting.feeds_limit.to_i
  #       render_feed(@messages, :title => "#{@project}: #{@board}")
  #     }
  #   end
  # end

  def show_with_sp
    respond_to do |format|
      format.html {
        sort_init 'updated_on', 'desc'
        sort_update 'created_on' => "#{Message.table_name}.created_on",
                    'replies' => "#{Message.table_name}.replies_count",
                    'updated_on' => "COALESCE(last_replies_messages.created_on, #{Message.table_name}.created_on)"

        @topic_count = @board.topics.count
        @topic_pages = Paginator.new @topic_count, per_page_option, params['page']
        @topics =  @board.topics.
          reorder("#{Message.table_name}.sticky DESC").
          includes(:last_reply).
          limit(@topic_pages.per_page).
          offset(@topic_pages.offset).
          order(sort_clause).
          preload(:author, {:last_reply => :author}).
          all
        @message = Message.new(:board => @board)
        render :action => 'show', :layout => !request.xhr?
      }
      format.atom {
        @messages = @board.messages.
          reorder('created_on DESC').
          includes(:author, :board).
          limit(Setting.feeds_limit.to_i).
          all
        render_feed(@messages, :title => "#{@project}: #{@board}")
      }
    end
  end