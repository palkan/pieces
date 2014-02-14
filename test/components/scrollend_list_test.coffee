describe "scroll_end list component", ->
  beforeEach ->
    @test_div = $(document.createElement('div'))
    @test_div.css position:'relative'
    $('body').append(@test_div)
    @test_div.append """
        <div class="pi" data-component="list" data-plugins="scroll_end" data-pi="test" style="position:relative; height: 30px;">
          <ul class="list" style="overflow-y:scroll;height:30px;">
            <li class="item" data-id="1" style="height:40px;" data-key="one">One<span class="tags">killer,puppy</span></li>
            <li class="item" data-id="2" style="height:40px;" data-key="someone">Two<span class="tags">puppy, coward</span></li>
            <li class="item" data-id="3" style="height:40px;" data-key="anyone">Tre<span class="tags">bully,zombopuppy</span></li>
          </ul>
        </div>
      """
    pi.piecify()
    @list = $('@test').pi()

  afterEach ->
    @test_div.remove()

  describe "scroll_end plugin", ->

    it "should send scroll_end event", (done)->  
      @list.on 'scroll_end', (event) =>
        done()  

      @list.items_cont.get(0).scrollTop = @list.items_cont.get(0).scrollHeight - @list.items_cont.get(0).clientHeight - 49

    it "should not send scroll_end event", (done)->  
      
      count = 0
      @list.on 'scroll_end', (event) =>
        count++

      after 500, =>
        done() if count is 0

      @list.items_cont.get(0).scrollTop = @list.items_cont.get(0).scrollHeight - @list.items_cont.get(0).clientHeight - 100 

    it "should send scroll_end event once per 500ms", (done)->  
      
      spy_fun = sinon.spy()

      @list.on 'scroll_end', spy_fun

      after 500, =>
        done() if spy_fun.callCount is 1

      @list.items_cont.get(0).scrollTop = @list.items_cont.get(0).scrollHeight - @list.items_cont.get(0).clientHeight - 49 
      after 200, =>
         @list.items_cont.get(0).scrollTop += 5
         

    it "should send scroll_end event twice per 1000ms", (done)->  
      
      spy_fun = sinon.spy()

      @list.on 'scroll_end', spy_fun

      after 1200, =>
       done() if spy_fun.callCount is 2

      @list.items_cont.get(0).scrollTop = @list.items_cont.get(0).scrollHeight - @list.items_cont.get(0).clientHeight - 40 

      after 200, =>
         @list.items_cont.get(0).scrollTop += 5

      after 550, =>
         @list.items_cont.get(0).scrollTop += 5

      after 1000, =>
         @list.items_cont.get(0).scrollTop += 5