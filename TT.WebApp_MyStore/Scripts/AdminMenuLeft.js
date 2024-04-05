var _api = {
    GetMenuSettings: "/API/AdminHandler.ashx?tbl=MenuSettings&func=GetAll",
    SetSelectMenu: "/API/AdminHandler.ashx?tbl=MenuSettings&func=SetSelectMenu",
    SetMenuNotify: "/API/AdminHandler.ashx?tbl=Notify&func=SetMenuNotify",
}


$(document).ready(function () {
    LoadJqueryTemplate('MenuLeft', ".sidebar-list", function () {
        $.ajax({
            url: _api.GetMenuSettings,
            data: null,
            type: "POST",
            scriptCharset: "utf8",
            dataType: "json",
            success: function (res) {
                if (res.status == "SUCCESS") {
                    $("#MenuLeftTemplate").tmpl({ data: res.data }).appendTo(".sidebar-list .iq-main-menu");

                    if (PageCurrentInfo != null) {
                        if (isNullOrEmpty(PageCurrentInfo.MenuParent) && isNullOrEmpty(PageCurrentInfo.MenuSelected))
                            $(".sidebar-list a").removeClass(" active");
                        else if (!isNullOrEmpty(PageCurrentInfo.MenuParent)) {
                            $("#" + PageCurrentInfo.MenuParent).addClass(" show");
                            $("#" + PageCurrentInfo.MenuSelected).addClass(" active");
                        }
                        else {
                            $("#" + PageCurrentInfo.MenuSelected).addClass(" active");
                        }
                    }
                }
            },
            error: function (e) {
            },
        });
    });

    LoadJqueryTemplate('MenuLeft', ".sidebar-list", function () {
        $.ajax({
            url: _api.GetMenuSettings,
            data: null,
            type: "POST",
            scriptCharset: "utf8",
            dataType: "json",
            success: function (res) {
                if (res.status == "SUCCESS") {
                    $("#MenuLeftTemplate").tmpl({ data: res.data }).appendTo(".sidebar-list .iq-main-menu");

                    if (PageCurrentInfo != null) {
                        if (isNullOrEmpty(PageCurrentInfo.MenuParent) && isNullOrEmpty(PageCurrentInfo.MenuSelected))
                            $(".sidebar-list a").removeClass(" active");
                        else if (!isNullOrEmpty(PageCurrentInfo.MenuParent)) {
                            $("#" + PageCurrentInfo.MenuParent).addClass(" show");
                            $("#" + PageCurrentInfo.MenuSelected).addClass(" active");
                        }
                        else {
                            $("#" + PageCurrentInfo.MenuSelected).addClass(" active");
                        }
                    }
                }
            },
            error: function (e) {
            },
        });
    });

    $('#languageIcon').on('click', function () {
        $.ajax({
            url: "/API/AdminHandler.ashx?tbl=User&func=UpdateLanguageId",
            data: null,
            type: "POST",
            scriptCharset: "utf8",
            dataType: "json",
            success: function (res) {
                if (res.status == "SUCCESS") {
                    window.location.reload(true);
                } else {
                    alert('err');
                }
            },
            error: function (e) {
            },
        });
    });

    $('.sidebar-list').on('click', 'ul li a', function (e) {
        var Parent = $(this).parents('ul:first').attr('id');
        var Selected = $(this).attr('id');

        $(".nav-link").attr("aria-expanded","false");
        $(".sidebar-list a").removeClass(" active");
        if (Selected.indexOf("ddlMenu") == -1) {
            $("#" + Selected).addClass(" active");
            var o = new Object;
            o.Parent = Parent;
            o.Selected = Selected;
            $.ajax({
                url: _api.SetSelectMenu,
                data: { data: JSON.stringify(o) },
                type: "POST",
                scriptCharset: "utf8",
                dataType: "json",
                success: function (res) {
                },
                error: function (e) {
                },
            });
        } else {
            $("#" + Selected).attr("aria-expanded", "true");
        }
    });

    $('.sidebar-header').on('click', '#IconHome', function () {
        var o = new Object;
        o.ClearMenu = true;
        $.ajax({
            url: _api.SetSelectMenu,
            data: { data: JSON.stringify(o) },
            type: "POST",
            scriptCharset: "utf8",
            dataType: "json",
            success: function (res) {
            },
            error: function (e) {
            },
        });
    });
});