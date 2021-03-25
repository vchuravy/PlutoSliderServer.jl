
## GITHUB ACTION
export github_action

using Logging: global_logger
using GitHubActions: GitHubActionsLogger
get(ENV, "GITHUB_ACTIONS", "false") == "true" && global_logger(GitHubActionsLogger())


"A convenience function to call from a GitHub Action. See [`export_paths`](@ref) for the list of keyword arguments."
function github_action(; generate_default_index=true, kwargs...)
    start_dir = "."

    export_directory(start_dir; kwargs...)

    generate_default_index && create_default_index()
end

"If no index.html, index.md, index.jl file exists, create a default index.md that GitHub Pages will render into an index page, listing all notebooks."
function create_default_index(;export_dir=".")
    default_md = """
    Notebooks:

    <ul>
        {% for page in site.static_files %}
            {% if page.extname == ".html" %}
                <li><a href="{{ page.path | absolute_url }}">{{ page.name }}</a></li>
            {% endif %}
        {% endfor %}
    </ul>

    <br>
    <br>
    <br>
    """

    exists = any(["index.html", "index.md", ("index"*e for e in pluto_file_extensions)...]) do f
        joinpath(export_dir, f) |> isfile
    end
    if !exists
        write(joinpath(export_dir, "index.md"), default_md)
    end
end

