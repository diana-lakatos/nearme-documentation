class MailerCssDrop < BaseDrop
  def btn
    %q{color: #FFFFFF !important;
    background-color: #024FA3 !important;
    padding: 15px;
    margin-right: 10px;
    text-align: center;
    cursor: pointer;
    display: inline-block;
    font-size: 16px !important; text-decoration: none !important;}
  end

  def h1
    %q{display:block; 
    font-family:"Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif; 
    font-size:28px; 
    font-style:normal; 
    font-weight:normal; 
    line-height:100%; 
    letter-spacing:normal; 
    margin-top:0; 
    margin-right:0; 
    margin-bottom:20px; 
    margin-left:0; 
    text-align:left; 
    padding:0;}
  end

  def h2
    %q{display:block; 
    font-family:"Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif; 
    font-size:26px; 
    font-style:normal; 
    font-weight:normal; 
    line-height:100%; 
    letter-spacing:normal; 
    margin-top:0; 
    margin-right:0; 
    margin-bottom:20px; 
    margin-left:0; 
    text-align:left; 
    padding:0;}
  end

  def h3
    %q{display:block; 
    font-family:"Helvetica Neue", Helvetica, Arial, "Lucida Grande", sans-serif; 
    font-size:16px; 
    font-style:normal; 
    font-weight:normal; 
    line-height:100%; 
    letter-spacing:normal; 
    margin-top:0; 
    margin-right:0; 
    margin-bottom:20px; 
    margin-left:0; 
    text-align:left; 
    padding:0;}
  end
end
