<%@ Page Language="C#" MasterPageFile="~/Pages/MasterPages/BlankMasterPage.Master" AutoEventWireup="true" CodeBehind="InsertUpdateUser.aspx.cs" Inherits="TT.WebApp_MyStore.Pages.InsertUpdateUser" %>

<asp:Content ID="ContentMy" ContentPlaceHolderID="BlankContent" runat="server">
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title></title>
</head>
<body>
   <div id='processcustome' style='display:none'>
        <img id='img-pro' src=''>
    </div>
    <div class='msgError'>
        <span id='messerror'></span>
    </div>
    <div class='Buttons' style='display:block;'>
        <input type="button" id="btnSave" class="btnSave" onclick="onSaveUser()" value="Lưu"  runat="server" />
    </div>
    <div class='FormBody Form-ds'>
        <div class='full-content'>
            <!-- <div class='TitleF Master-Title'>
                <span id='WorkflowTitle'>Thông tin nhân viên</span>
            </div> -->
            <div id='UpdateInfo' class='title-child'  runat="server">Thông tin chung</div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbAccountName'  runat="server">Tên tài khoản</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtAccountName'  class="form-control" style="width: auto;" />
                        <span id='lb_Value_ddlAccountName'></span>
                    </div>
                </div>
                <div class='ItemText Text'>
                    <span id='lbFullName'  runat="server">Tên đầy đủ</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtFullName'  class="form-control" style="width: auto;" />
                        <span id='lb_Value_txtFullName'></span>
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbEmail'  runat="server">Email</span><label> (*)</label>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                         <input id='txtEmail'  class="form-control" style="width: auto;" />
                        <span id='lb_Value_txtEmail'></span>
                    </div>
                </div>
                <div class='ItemText Text'>
                    <span id='lbPermission'  runat="server">Phân quyền</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='dllPermission'  class="form-control" style="width: 210px;" />
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbGender'  runat="server">Giới tính</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input type='checkbox' id='ckGender'  class="form-control" style="width: 210px;" />
                    </div>
                </div>
                <div class='ItemText Text'>
                    <span id='lbBirthDay'  runat="server">Ngày sinh</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtBirthDay'  class="form-control" style="width: auto;" />
                        <span id='lb_Value_txtBirthDay'></span>
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbAddress'  runat="server">Địa chỉ</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtAddress'  class="form-control" style="width: auto;" />
                        <span id='lb_Value_txtAddress'></span>
                    </div>
                </div>
                 <div class='ItemText Text'>
                    <span id='lbMobile'  runat="server">Số điện thoại</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input id='txtMobile'  class="form-control" style="width: auto;" type='number' />
                        <span id='lb_Value_txtMobile'></span>
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbPosition'  runat="server">Chức vụ</span>
                </div>
                <div class='ItemInput Input'>
                      <div class='ItemControl'>
                        <input id='dllPosition'  class="form-control" style="width: 210px;" />
                    </div>
                </div>
                 <div class='ItemText Text'>
                    <span id='lbStatus' style="margin-left: 92px;"  runat="server">Trạng thái</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input type='checkbox' id='ckStatus'  class="form-control" style="width: 210px;" />
                    </div>
                </div>
            </div>
            <div class='ItemRow col-md-12'>
                <div class='ItemText Text'>
                    <span id='lbImage'  runat="server">Ảnh đại diện</span>
                </div>
                <div class='ItemInput Input'>
                    <div class='ItemControl'>
                        <input type='file' id='fuTemplate' accept='.jpg,.png' class="form-control" style="width: 210px;" />
                         <div id="products"></div>
                        <script type="text/x-kendo-template" id="template">
                            <div class="product"><img src="../content/web/foods/#= name #" alt="#: name # image" /></div>       
                        </script>
                    </div>
                </div>
            </div>
             
        </div>
    </div>
    <script src="../Scripts/InsertUpdateUser.js"></script>
</body>
</html>
</asp:Content>
